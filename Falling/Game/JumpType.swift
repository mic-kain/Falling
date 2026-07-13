import SpriteKit

/// Touch-zone jump selection (GAMEPLAY_RULES.md §5.1, §5.3).
enum JumpType: Equatable {
    case small
    case long

    /// Launch velocity in world units/s.
    /// Gameplay rules specify upward launches as negative values in the
    /// design docs; this scene uses an upward-positive Y axis.
    var launchVelocity: CGVector {
        switch self {
        case .small:
            CGVector(
                dx: WorldConstants.smallJumpHorizontalVelocity,
                dy: -WorldConstants.smallJumpVerticalVelocity
            )
        case .long:
            CGVector(
                dx: WorldConstants.longJumpHorizontalVelocity,
                dy: -WorldConstants.longJumpVerticalVelocity
            )
        }
    }
}
