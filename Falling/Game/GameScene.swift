import SpriteKit

/// Minimal vertical-slice scene: one static platform, one player falling under gravity.
/// Physics runs on the fixed-timestep simulator; this scene only presents state.
final class GameScene: SKScene {
    private var simulator: FixedTimestepSimulator?
    private var playerNode: SKSpriteNode?
    private var platformNode: SKSpriteNode?

    /// Player centre position in world units.
    private var playerPosition = CGPoint.zero
    /// Player velocity in world units per second.
    private var playerVelocity = CGVector.zero

    private var didPlaceInitialLayout = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1)

        // Anchor at bottom-left so world Y increases upward (standard physics).
        anchorPoint = .zero

        ensureNodesExist()
        placeInitialLayoutIfNeeded()
        startSimulation()
    }

    override func willMove(from view: SKView) {
        simulator?.stop()
        simulator = nil
    }

    override func didChangeSize(_ oldSize: CGSize) {
        ensureNodesExist()
        placeInitialLayoutIfNeeded()
    }

    // MARK: - World setup (world units)

    private func ensureNodesExist() {
        guard platformNode == nil else { return }

        let platform = SKSpriteNode(color: SKColor(white: 0.55, alpha: 1), size: WorldConstants.platformSize)
        platform.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(platform)
        platformNode = platform

        let player = SKSpriteNode(color: SKColor(white: 0.95, alpha: 1), size: WorldConstants.playerSize)
        player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(player)
        playerNode = player
    }

    private func placeInitialLayoutIfNeeded() {
        guard !didPlaceInitialLayout, size.width > 0, size.height > 0 else { return }
        guard let platformNode, let playerNode else { return }

        // Centre horizontally in the reference world; near the bottom vertically.
        let platformCenter = CGPoint(
            x: size.width * 0.5,
            y: WorldConstants.platformBottomOffset + WorldConstants.platformSize.height * 0.5
        )
        platformNode.position = platformCenter

        // Rest player on the platform top surface at scene start.
        playerPosition = CGPoint(
            x: platformCenter.x,
            y: platformCenter.y
                + WorldConstants.platformSize.height * 0.5
                + WorldConstants.playerSize.height * 0.5
        )
        playerVelocity = .zero
        playerNode.position = playerPosition
        didPlaceInitialLayout = true
    }

    // MARK: - Fixed-timestep simulation

    private func startSimulation() {
        simulator?.stop()

        let simulator = FixedTimestepSimulator { [weak self] dt in
            self?.simulate(dt)
        }
        self.simulator = simulator
        simulator.start()
    }

    /// One authoritative physics step. `dt` is always `WorldConstants.physicsStep`.
    private func simulate(_ dt: TimeInterval) {
        // Gravity pulls downward (negative Y) at 1,200 world units/s².
        playerVelocity.dy -= WorldConstants.gravity * CGFloat(dt)
        playerPosition.x += playerVelocity.dx * CGFloat(dt)
        playerPosition.y += playerVelocity.dy * CGFloat(dt)

        playerNode?.position = playerPosition
    }
}
