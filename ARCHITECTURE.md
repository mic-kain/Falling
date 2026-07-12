# Falling — Technical Architecture (Tier 1)

Status: Locked for Tier 1 MVP implementation.

## 8. Technical Architecture

| Area | Locked decision |
|---|---|
| Platform | Native iPhone only, portrait orientation. |
| Language | Swift. |
| Gameplay | SpriteKit scene and native Swift systems. |
| Application UI | SwiftUI for menus, settings, pause, tutorial overlays and Game Over. |
| Hosting | SpriteKit hosted inside the SwiftUI app using SpriteView or equivalent native bridge. |
| Rendering | Edge-to-edge SpriteKit gameplay, safe-area-respecting SwiftUI HUD. |
| Simulation | Authoritative fixed timestep at 1/120 second, decoupled from rendering. |
| Collision | SpriteKit contacts plus swept top-surface collision from previous to current player position. |
| World management | Object pooling, active world window and floating origin. |
| Storage | Local settings, tutorial completion and personal best. No account required. |

### 8.1 Fixed-Timestep Simulation

physicsStep = 1 / 120 second
accumulator += min(frameDelta, 0.1)
while accumulator >= physicsStep: simulate(physicsStep); accumulator -= physicsStep

- Rendering may occur at 60 Hz or up to 120 Hz on ProMotion devices without changing gameplay.
- All physics, crumble timers, coyote time, buffering and correction windows use elapsed time.
- Animation, particles, camera and audio never determine gameplay outcomes.

### 8.2 Coordinate Separation

| Space | Use |
|---|---|
| World units | Physics, jump calculation, procedural generation, camera and difficulty. |
| Points | SwiftUI layout, safe areas, HUD and touch coordinates. |
| Pixels | Renderer output only. Never used by gameplay logic. |

Reference gameplay width is 390 logical world units. The runtime maps this fixed logical width to the actual gameplay view width in points while preserving gameplay difficulty across iPhones.

### 8.3 Lifecycle and Performance

- Automatically pause when the app resigns active status, enters background or is covered by a system interruption.
- Clear active touches and buffered input on interruption. Do not resume until the player taps Resume.
- Target stable 60 fps on the baseline supported iPhone and allow 120 Hz presentation where sustainable.
- No visible hitch during platform generation or recycling.
- No sustained memory growth during repeated or very long runs.
- When presentation quality must be reduced, only particles, trails or visual density may change; physics and difficulty remain identical.
