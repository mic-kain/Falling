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

## Vertical slice (current)

Edge-to-edge SpriteKit scene hosted in SwiftUI via `SpriteView`. A grey platform sits near the bottom; a white player rectangle starts on top of it and immediately falls under gravity (1,200 world units/s²) using the authoritative 1/120 s fixed-timestep loop. No input, landing collision, scoring, or abyss death yet.
