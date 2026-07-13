# Falling

Native iPhone arcade game. See `ARCHITECTURE.md` and `GAMEPLAY_RULES.md` for the locked Tier 1 spec.

## Requirements

- Xcode 15 or later
- iOS 17+ SDK
- iPhone simulator or device (portrait only)

## Run

1. Open `Falling.xcodeproj` in Xcode.
2. Select an iPhone simulator (for example iPhone 16).
3. Press Run (⌘R).

Simulator builds do not require a development team. Device builds still use normal Xcode signing.

From Terminal on macOS:

```bash
xcodebuild -scheme Falling -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Vertical slice (current)

Edge-to-edge SpriteKit scene hosted in SwiftUI via `SpriteView`. Two static platforms: the player spawns grounded on the first, stays stationary while grounded, and jumps via two-zone touch input (left = Small Jump, right = Long Jump). Swept top-surface collision resolves landings; gravity and jump velocities use locked depth-0 values. No crumble timers, procedural generation, camera follow, scoring, HUD, or abyss death yet.

### Controls

- Tap the **left half** of the screen for a Small Jump (260 wu/s horizontal, -420 wu/s vertical).
- Tap the **right half** (including centreline) for a Long Jump (390 wu/s horizontal, -500 wu/s vertical).
- Input is enabled after 0.75 s spawn lockout.
