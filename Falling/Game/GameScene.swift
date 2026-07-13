import SpriteKit

/// Gameplay scene: static platforms, swept landing, grounded behaviour, two-zone jumps.
final class GameScene: SKScene {
    private var simulator: FixedTimestepSimulator?
    private var isSimulationRunning = false
    private var playerNode: SKSpriteNode?
    private var platformNodes: [UUID: SKSpriteNode] = [:]

    private var platforms: [Platform] = []
    private var playerPosition = CGPoint.zero
    private var playerVelocity = CGVector.zero
    private var playerState: PlayerState = .grounded
    private var groundedPlatformID: UUID?
    private var elapsedSimulationTime: TimeInterval = 0
    private var didPlaceInitialLayout = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1)
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
        placeInitialLayoutIfNeeded()
        startSimulationIfReady()
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
        guard playerNode == nil else { return }

        let player = SKSpriteNode(color: SKColor(white: 0.95, alpha: 1), size: WorldConstants.playerSize)
        player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        player.zPosition = 10
        addChild(player)
        playerNode = player
    }

    private func placeInitialLayoutIfNeeded() {
        guard !didPlaceInitialLayout, size.width > 0, size.height > 0 else { return }

        platforms = makeStaticPlatforms()
        syncPlatformNodes()

        guard let startPlatform = platforms.first else { return }

        playerPosition = spawnPosition(on: startPlatform)
        playerVelocity = .zero
        playerState = .grounded
        groundedPlatformID = startPlatform.id
        playerNode?.position = playerPosition
        didPlaceInitialLayout = true
    }

    private func makeStaticPlatforms() -> [Platform] {
        let startCenter = CGPoint(
            x: size.width * 0.5,
            y: WorldConstants.platformBottomOffset + WorldConstants.platformSize.height * 0.5
        )

        return [
            Platform(center: startCenter, size: WorldConstants.platformSize),
            Platform(center: WorldConstants.secondPlatformCenter, size: WorldConstants.secondPlatformSize),
        ]
    }

    private func syncPlatformNodes() {
        let liveIDs = Set(platforms.map(\.id))

        for id in platformNodes.keys where !liveIDs.contains(id) {
            platformNodes[id]?.removeFromParent()
            platformNodes.removeValue(forKey: id)
        }

        for platform in platforms {
            let node: SKSpriteNode
            if let existing = platformNodes[platform.id] {
                node = existing
            } else {
                let created = SKSpriteNode(color: SKColor(white: 0.55, alpha: 1), size: platform.size)
                created.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                created.zPosition = 0
                addChild(created)
                platformNodes[platform.id] = created
                node = created
            }

            node.position = platform.center
            node.size = platform.size
        }
    }

    private func spawnPosition(on platform: Platform) -> CGPoint {
        CGPoint(
            x: platform.center.x,
            y: platform.topSurfaceY + WorldConstants.playerSize.height * 0.5
        )
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
            playerNode?.position = playerPosition
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

        playerNode?.position = playerPosition
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
