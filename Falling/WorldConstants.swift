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

    // MARK: - Vertical-slice layout (world units)

    static let platformSize = CGSize(width: 200, height: 24)
    /// Platform top surface sits this far above the scene bottom.
    static let platformBottomOffset: CGFloat = 80

    static let playerSize = CGSize(width: 28, height: 40)
}
