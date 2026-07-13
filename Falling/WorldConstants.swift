import CoreGraphics
import Foundation

/// Locked gameplay constants from ARCHITECTURE.md and GAMEPLAY_RULES.md.
/// Physics and placement use world units only — never points or pixels.
enum WorldConstants {
    /// Reference gameplay width (ARCHITECTURE.md §8.2).
    static let referenceWidth: CGFloat = 390

    /// Gravity magnitude in world units/s² (GAMEPLAY_RULES.md §5.3).
    static let gravity: CGFloat = 1_200

    /// Authoritative fixed physics step (ARCHITECTURE.md §8.1).
    static let physicsStep: TimeInterval = 1.0 / 120.0

    /// Maximum frame delta added to the accumulator (ARCHITECTURE.md §8.1).
    static let maxFrameDelta: TimeInterval = 0.1

    // MARK: - Jump physics at depth 0 (GAMEPLAY_RULES.md §5.3)

    static let smallJumpHorizontalVelocity: CGFloat = 260
    static let smallJumpVerticalVelocity: CGFloat = -420
    static let longJumpHorizontalVelocity: CGFloat = 390
    static let longJumpVerticalVelocity: CGFloat = -500
    static let maxFallVelocityAtDepth0: CGFloat = 1_450

    /// Maximum input-disabled period after spawn (GAMEPLAY_RULES.md §4).
    static let spawnInputLockout: TimeInterval = 0.75

    // MARK: - Layout (world units)

    static let platformSize = CGSize(width: 200, height: 24)
    static let platformBottomOffset: CGFloat = 80
    static let playerSize = CGSize(width: 28, height: 40)

    /// Second test platform: reachable by Small Jump to the right with a modest drop.
    static let secondPlatformCenter = CGPoint(x: 310, y: 56)
    static let secondPlatformSize = CGSize(width: 120, height: 24)
}
