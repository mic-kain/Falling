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

    /// Nearest / spawn ledge width — spans most of the screen at scale 1 (look-down).
    static let startPlatformSize = CGSize(width: 340, height: 28)

    /// Depth-field demo ledges (ARCHITECTURE.md §8.4 multi-ledge paragraph).
    /// `lateral` is world X offset from shaft centre; `depth` is world Y below the start ledge centre.
    /// Depths are spaced across `PresentationConstants.fullVanishingDepth` so some ledges sit
    /// near the feet, some mid-shaft, and some small at the centre vanishing point.
    static let depthFieldLedges: [(lateral: CGFloat, depth: CGFloat, size: CGSize)] = [
        (-110, 70, CGSize(width: 150, height: 26)),
        (105, 140, CGSize(width: 130, height: 26)),
        (-40, 220, CGSize(width: 170, height: 26)),
        (125, 300, CGSize(width: 120, height: 26)),
        (-130, 380, CGSize(width: 140, height: 26)),
        (60, 460, CGSize(width: 160, height: 26)),
        (-90, 540, CGSize(width: 110, height: 26)),
        (100, 620, CGSize(width: 145, height: 26)),
        (15, 700, CGSize(width: 155, height: 26)),
        (-115, 800, CGSize(width: 125, height: 26)),
        (85, 900, CGSize(width: 135, height: 26)),
    ]
}
