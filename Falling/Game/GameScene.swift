import SpriteKit

/// Gameplay scene: static platforms, swept landing, grounded behaviour, two-zone jumps.
/// Presentation uses a look-down depth projection (ARCHITECTURE.md §8.4).
final class GameScene: SKScene {
    private var simulator: FixedTimestepSimulator?
    private var isSimulationRunning = false
    private var playerNode: SKSpriteNode?
    private var platformNodes: [UUID: SKSpriteNode] = [:]
    private var shaftGuideNode: SKNode?
    private var buildStampNode: SKLabelNode?

    private var platforms: [Platform] = []
    private var playerPosition = CGPoint.zero
    private var playerVelocity = CGVector.zero
    private var playerState: PlayerState = .grounded
    private var groundedPlatformID: UUID?
    private var elapsedSimulationTime: TimeInterval = 0
    private var didPlaceInitialLayout = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 1)
        anchorPoint = .zero
        isUserInteractionEnabled = true

        ensureNodesExist()
        placeInitialLayoutIfNeeded()
        startSimulationIfReady()
    }

    override func willMove(from view: SKView) {
        simulator?.stop()
        simulator = nil
        isSimulationRunning = false
    }

    override func didChangeSize(_ oldSize: CGSize) {
        ensureNodesExist()
        rebuildShaftGuides()
        layoutBuildStamp()
        placeInitialLayoutIfNeeded()
        startSimulationIfReady()
        updatePresentation()
    }

    // MARK: - Touch input (GAMEPLAY_RULES.md §5.1)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard elapsedSimulationTime >= WorldConstants.spawnInputLockout else { return }
        guard playerState == .grounded else { return }

        let location = touch.location(in: self)
        let jumpType: JumpType = location.x < size.width * 0.5 ? .small : .long
        launchJump(jumpType)
    }

    // MARK: - World setup

    private func ensureNodesExist() {
        if shaftGuideNode == nil {
            rebuildShaftGuides()
        }
        ensureBuildStamp()

        guard playerNode == nil else { return }

        // Feet / lower-body footprint — sells look-down, not a side-view body.
        let feet = SKSpriteNode(
            color: SKColor(red: 1, green: 0.45, blue: 0.1, alpha: 1),
            size: PresentationConstants.playerFeetPresentationSize
        )
        feet.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        feet.zPosition = 100
        addChild(feet)
        playerNode = feet
    }

    /// Bright on-screen stamp so a stale Desktop binary is obvious.
    private func ensureBuildStamp() {
        guard buildStampNode == nil else { return }
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "LOOK-DOWN+SIGNING cf3704a"
        label.fontSize = 14
        label.fontColor = SKColor(red: 0.2, green: 1, blue: 0.4, alpha: 1)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        label.zPosition = 1_000
        addChild(label)
        buildStampNode = label
        layoutBuildStamp()
    }

    private func layoutBuildStamp() {
        guard size.width > 0, size.height > 0 else { return }
        buildStampNode?.position = CGPoint(x: 12, y: size.height - 12)
    }

    private func rebuildShaftGuides() {
        shaftGuideNode?.removeFromParent()
        guard size.width > 0, size.height > 0 else { return }

        let root = SKNode()
        root.zPosition = -1_000

        let vanishingPoint = PresentationConstants.vanishingPoint(in: size)
        let playerAnchor = PresentationConstants.playerAnchor(in: size)

        // Converging shaft edges: look-down cavern cues from centre VP toward the feet.
        let edgeColor = SKColor(white: 0.22, alpha: 1)
        let leftEdge = shaftLine(
            from: vanishingPoint,
            to: CGPoint(x: size.width * 0.02, y: playerAnchor.y * 0.35),
            color: edgeColor
        )
        let rightEdge = shaftLine(
            from: vanishingPoint,
            to: CGPoint(x: size.width * 0.98, y: playerAnchor.y * 0.35),
            color: edgeColor
        )
        root.addChild(leftEdge)
        root.addChild(rightEdge)

        // Depth rings around the vanishing point reinforce "falling into the screen".
        for ringScale: CGFloat in [0.06, 0.12, 0.2, 0.32] {
            let ring = SKShapeNode(circleOfRadius: min(size.width, size.height) * ringScale)
            ring.position = vanishingPoint
            ring.strokeColor = SKColor(white: 0.18, alpha: 1)
            ring.fillColor = .clear
            ring.lineWidth = 1
            ring.glowWidth = 0
            root.addChild(ring)
        }

        let vanishingMarker = SKShapeNode(circleOfRadius: 10)
        vanishingMarker.position = vanishingPoint
        vanishingMarker.fillColor = SKColor(red: 0.15, green: 1, blue: 0.35, alpha: 1)
        vanishingMarker.strokeColor = SKColor(white: 1, alpha: 0.9)
        vanishingMarker.lineWidth = 2
        root.addChild(vanishingMarker)

        addChild(root)
        shaftGuideNode = root
    }

    private func shaftLine(from: CGPoint, to: CGPoint, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let node = SKShapeNode(path: path)
        node.strokeColor = color
        node.lineWidth = 1.5
        node.glowWidth = 0
        return node
    }

    private func placeInitialLayoutIfNeeded() {
        guard !didPlaceInitialLayout, size.width > 0, size.height > 0 else { return }

        platforms = makeStaticPlatforms()
        syncPlatformNodes()

        guard let startPlatform = platforms.first else { return }

        // Stand on the nearest ledge so it reads large at the bottom feet anchor
        // while deeper ledges remain small toward the centre vanishing point.
        playerPosition = spawnPosition(on: startPlatform)
        playerVelocity = .zero
        playerState = .grounded
        groundedPlatformID = startPlatform.id
        didPlaceInitialLayout = true
        updatePresentation()
    }

    private func makeStaticPlatforms() -> [Platform] {
        let shaftCenterX = WorldConstants.referenceWidth * 0.5
        let startCenter = CGPoint(
            x: shaftCenterX,
            y: WorldConstants.platformBottomOffset + WorldConstants.startPlatformSize.height * 0.5
        )

        var platforms = [
            Platform(center: startCenter, size: WorldConstants.startPlatformSize)
        ]

        for ledge in WorldConstants.depthFieldLedges {
            platforms.append(
                Platform(
                    center: CGPoint(x: shaftCenterX + ledge.lateral, y: startCenter.y - ledge.depth),
                    size: ledge.size
                )
            )
        }

        return platforms
    }

    private func syncPlatformNodes() {
        let liveIDs = Set(platforms.map(\.id))

        for id in platformNodes.keys where !liveIDs.contains(id) {
            platformNodes[id]?.removeFromParent()
            platformNodes.removeValue(forKey: id)
        }

        for (index, platform) in platforms.enumerated() {
            let node: SKSpriteNode
            if let existing = platformNodes[platform.id] {
                node = existing
            } else {
                // Placeholder shades so overlapping ledges stay readable in the depth field.
                let shade = 0.38 + CGFloat(index % 5) * 0.07
                let created = SKSpriteNode(color: SKColor(white: shade, alpha: 1), size: platform.size)
                created.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                created.zPosition = 0
                addChild(created)
                platformNodes[platform.id] = created
                node = created
            }

            node.size = platform.size
        }

        updatePresentation()
    }

    private func spawnPosition(on platform: Platform) -> CGPoint {
        CGPoint(
            x: platform.center.x,
            y: platform.topSurfaceY + WorldConstants.playerSize.height * 0.5
        )
    }

    // MARK: - Presentation (ARCHITECTURE.md §8.4)

    override func update(_ currentTime: TimeInterval) {
        updatePresentation()
    }

    private func updatePresentation() {
        guard didPlaceInitialLayout, size.width > 0, size.height > 0 else { return }

        if let playerNode {
            let projectedPlayer = DepthProjection.projectPlayer(viewportSize: size)
            playerNode.position = projectedPlayer.position
            playerNode.size = projectedPlayer.size
            playerNode.zPosition = 100
        }

        for platform in platforms {
            guard let node = platformNodes[platform.id] else { continue }

            let projectedPlatform = DepthProjection.projectPlatform(
                platform: platform,
                playerWorldCenter: playerPosition,
                playerWorldSize: WorldConstants.playerSize,
                viewportSize: size
            )

            node.position = projectedPlatform.position
            node.size = projectedPlatform.size
            // Nearer ledges draw above farther ones.
            node.zPosition = 50 - projectedPlatform.projectionT * 40
            node.alpha = projectedPlatform.projectionT >= 0.98 ? 0.85 : 1
        }
    }

    // MARK: - Simulation

    private func startSimulation() {
        simulator?.stop()

        let simulator = FixedTimestepSimulator { [weak self] dt in
            self?.simulate(dt)
        }
        self.simulator = simulator
        simulator.start()
        isSimulationRunning = true
    }

    private func startSimulationIfReady() {
        guard didPlaceInitialLayout, !isSimulationRunning else { return }
        startSimulation()
    }

    private func launchJump(_ jumpType: JumpType) {
        playerVelocity = CGVector(dx: jumpType.horizontalVelocity, dy: jumpType.verticalVelocity)
        playerState = .jumping
        groundedPlatformID = nil
    }

    private func simulate(_ dt: TimeInterval) {
        elapsedSimulationTime += dt

        if playerState == .grounded {
            maintainGroundedState()
            return
        }

        let previousPosition = playerPosition

        playerVelocity.dy = max(
            playerVelocity.dy - WorldConstants.gravity * CGFloat(dt),
            -WorldConstants.maxFallVelocityAtDepth0
        )
        playerPosition.x += playerVelocity.dx * CGFloat(dt)
        playerPosition.y += playerVelocity.dy * CGFloat(dt)

        if playerVelocity.dy > 0, playerState == .jumping {
            playerState = .falling
        }

        if let landing = SweptCollision.findLanding(
            previousPosition: previousPosition,
            currentPosition: playerPosition,
            playerSize: WorldConstants.playerSize,
            platforms: platforms
        ) {
            playerPosition = landing.position
            playerVelocity = .zero
            playerState = .grounded
            groundedPlatformID = landing.platformID
        }
    }

    private func maintainGroundedState() {
        guard let groundedPlatformID,
              let platform = platforms.first(where: { $0.id == groundedPlatformID }) else {
            playerState = .falling
            return
        }

        playerVelocity = .zero
        playerPosition = CGPoint(
            x: platform.center.x,
            y: platform.topSurfaceY + WorldConstants.playerSize.height * 0.5
        )
    }
}
