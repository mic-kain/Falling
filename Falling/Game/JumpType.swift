/// Touch-zone jump selection (GAMEPLAY_RULES.md §5.1, §5.3).
enum JumpType: Equatable {
    case small
    case long

    var horizontalVelocity: CGFloat {
        switch self {
        case .small: WorldConstants.smallJumpHorizontalVelocity
        case .long: WorldConstants.longJumpHorizontalVelocity
        }
    }

    var verticalVelocity: CGFloat {
        switch self {
        case .small: WorldConstants.smallJumpVerticalVelocity
        case .long: WorldConstants.longJumpVerticalVelocity
        }
    }
}
