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

    /// Nearest / spawn ledge width — large enough to read as near-full width at scale 1.
    static let startPlatformSize = CGSize(width: 300, height: 24)

    /// Depth-field demo ledges (ARCHITECTURE.md §8.4 multi-ledge paragraph).
    /// `lateral` is world X offset from shaft centre; `depth` is world Y below the start ledge centre.
    static let depthFieldLedges: [(lateral: CGFloat, depth: CGFloat, size: CGSize)] = [
        (-120, 95, CGSize(width: 140, height: 22)),
        (100, 175, CGSize(width: 120, height: 22)),
        (-35, 255, CGSize(width: 160, height: 22)),
        (135, 340, CGSize(width: 110, height: 22)),
        (-140, 420, CGSize(width: 130, height: 22)),
        (55, 500, CGSize(width: 150, height: 22)),
        (-85, 585, CGSize(width: 100, height: 22)),
        (115, 670, CGSize(width: 145, height: 22)),
        (0, 755, CGSize(width: 170, height: 22)),
        (-105, 840, CGSize(width: 125, height: 22)),
        (90, 925, CGSize(width: 135, height: 22)),
    ]
}
