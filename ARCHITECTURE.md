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
| Rendering | Top-down depth camera. Player feet/lower body rendered near a fixed screen anchor; platforms and cavern geometry scale up from a vanishing point as depth-to-player decreases, creating a falling-into-an-endless-shaft illusion. Achieved via 2D scale and position projection in SpriteKit, no 3D engine required. |
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


### 8.4 Depth Projection Model

World depth and world lateral offset remain the only inputs to physics and procedural generation, exactly as specified in section 8.2 and in GAMEPLAY_RULES.md. This subsection covers presentation only.

The vanishing point is a fixed point at the center of the screen, not at the top. The player's feet and lower body render near a fixed anchor at the bottom of the screen, standing on the nearest ledge, which renders large and spans most of the screen width. This sells a first-person look-down viewpoint of the player falling into the screen.

Each upcoming ledge spawns small at the center vanishing point and grows in scale while moving downward from center toward the bottom player anchor as its depth-to-player decreases. Ledges never move upward or outward from the edges; all motion is outward-and-downward from center toward the bottom anchor.

The renderer maps a platform's lateral world offset into a horizontal screen offset scaled by the same projection factor used for scale, so gaps continue to read as left or right of center as they close in, while the platform still moves downward toward the bottom anchor.

A looping cavern-wall texture renders around the center vanishing point and scrolls outward and downward with depth to reinforce an endless-shaft feeling of falling into the screen.

This projection is cosmetic only. Gameplay, collision and difficulty scaling continue to operate entirely in world units and never read screen-space values.


Multiple ledges from the active world window render simultaneously, not one at a time. Ledges are scattered at varied lateral offsets across the shaft, some left of center, some right of center, some near center, and at varied depths, matching the scattered multi-ledge reference layout for Tier 1. Each visible ledge independently follows the same center-vanishing-point projection described above: it spawns small near center at its own depth and grows while moving toward the bottom anchor as depth-to-player decreases, regardless of what any other visible ledge is doing.
