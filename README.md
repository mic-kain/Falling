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

Edge-to-edge SpriteKit scene hosted in SwiftUI via `SpriteView`. Physics and collision remain in world units on the fixed 1/120 s timestep. A cosmetic depth projection layer (ARCHITECTURE.md §8.4) maps world depth and lateral offset into screen scale/position only: the player feet anchor near the lower-middle of the screen, distant platforms shrink toward an upper-centre vanishing point, and nearer platforms grow toward the anchor as depth-to-player decreases.

### Controls

- Tap the **left half** of the screen for a Small Jump (260 wu/s horizontal, -420 wu/s vertical).
- Tap the **right half** (including centreline) for a Long Jump (390 wu/s horizontal, -500 wu/s vertical).
- Input is enabled after 0.75 s spawn lockout.
