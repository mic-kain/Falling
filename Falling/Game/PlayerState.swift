/// Authoritative player states (GAMEPLAY_RULES.md §4).
enum PlayerState: Equatable {
    case grounded
    case jumping
    case falling
}
