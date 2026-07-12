# Falling — Tier 1 Procedural Generation

Status: Locked for Tier 1 MVP implementation.

## 7. Jump Physics and Infinite Gap Scaling

Horizontal gap distance has no fixed maximum. Most additional range comes from progressively larger vertical drops, which create more airtime. A slower sublinear velocity increase keeps deep runs fast and responsive without making jumps unreadably abrupt.

depthFactor = totalDepthDescended / 1000
velocityScale = 1 + (0.055 times the square root of depthFactor)
smallVx = 260 times velocityScale
smallVy = -420 times velocityScale
longVx = 390 times velocityScale
longVy = -500 times velocityScale
maxFallVelocity = 1450 + (90 times the square root of depthFactor)

Gravity remains fixed at 1,200 world units/s^2. The ratio between Long and Small horizontal velocity remains 1.5 at every depth, preserving a readable difference between the two actions.

targetVerticalDrop = 130 + (42 times depthFactor)
candidateVerticalDrop = targetVerticalDrop times random(0.88, 1.12)

The candidate vertical drop may continue growing indefinitely, but one transition may not exceed 1.45 times the previous primary vertical drop. Every candidate is still bounded by current physics, camera readability and authoritative reachability validation.

## 9. Tier 1 Procedural Generation

Tier 1 generates a single continuous required route using only static, level, rectangular Standard Crumbling Platforms. There are no branches, special platform classes, movement, wind, hazards or optional routes.

### 9.1 Generation Sequence

1. Calculate current depthFactor and shared physics values.
2. Select route direction and intended jump type.
3. Generate candidate vertical drop.
4. Calculate Small and Long nominal distances.
5. Generate target platform width and crumble duration.
6. Place the target in the intended jump region outside the ambiguity band.
7. Run authoritative nominal, wrong-jump, late-launch and coyote-boundary validation.
8. Accept the candidate or retry. Use an emergency platform if normal attempts fail.

### 9.2 Direction and Jump-Type Distribution

| Rule | Value |
|---|---|
| Reverse previous direction | 45% target probability |
| Continue previous direction | 35% target probability |
| Nearly vertical | 20% target probability |
| Maximum same-direction jumps | 4 |
| Small/Long at depthFactor 0-2 | 70% / 30% |
| Small/Long at depthFactor 2-8 | Interpolate toward 55% / 45% |
| Small/Long above depthFactor 8 | 45% / 55% |
| Maximum consecutive Small Jumps | 4 |
| Maximum consecutive Long Jumps | 3 |

### 9.3 Platform Width Scaling

nominalWidth = 34 + 121 / (1 + 0.22 times depthFactor to the power 0.90)
candidateWidth = nominalWidth times random(0.82, 1.18)
finalWidth = clamp(candidateWidth, 34, 190)

| Depth | Depth factor | Nominal width |
|---|---|---|
| 0 | 0 | 155 |
| 1,000 | 1 | 133 |
| 5,000 | 5 | 97 |
| 10,000 | 10 | 78 |
| 20,000 | 20 | 62 |
| 50,000 | 50 | 48 |
| 100,000 | 100 | 42 |

Absolute minimum usable landing width is 34 world units and may never be less than playerCollisionWidth + 6. Long Jump targets may receive a 1.02-1.12 width modifier; Small Jump targets may receive a 0.94-1.02 modifier. Validation always overrides the modifier.

### 9.4 Crumble Timing

depthCrumbleTime = 5.0 / (1 + 0.115 times the square root of depthFactor)
candidateCrumbleTime = depthCrumbleTime times random(0.90, 1.10)
crumbleDuration = clamp(candidateCrumbleTime, 0.85, 5.5 seconds)

| Depth | Typical crumble duration |
|---|---|
| 0 | 4.5-5.5 s |
| 1,000 | 4.0-4.8 s |
| 5,000 | 3.4-4.1 s |
| 10,000 | 3.0-3.7 s |
| 20,000 | 2.6-3.3 s |
| 50,000 | 2.1-2.8 s |

The first two tutorial platforms use at least 7.0 seconds. After the 0.85-second floor is reached, additional difficulty comes from narrower ledges, larger gaps and faster movement rather than still shorter required timers.

### 9.5 Authoritative Crumble and Collider Timeline

| Progress | Visual behaviour | Collision behaviour |
|---|---|---|
| 0-35% | Hairline cracks, light dust. | Full usable collider. No shrinkage. |
| 35-65% | Cracks spread, small decorative debris. | Full usable collider. No shrinkage. |
| 65-85% | Urgent edge damage below or outside the usable top silhouette. | Full usable collider. No shrinkage. |
| 85-100% | Major collapse warning; platform may narrow around the player. | Collider may erode only outside the protected player support region. |
| 100% | Platform fully collapses. | All remaining collision removed; 80 ms coyote time begins. |

The protected support region is the player's horizontal collision bounds expanded by a 6-world-unit safety margin on each side. Collision may never be removed from beneath the stationary grounded player before 100% collapse. Visual and collision geometry must match wherever the usable top surface changes.

### 9.6 Small/Long Ambiguity Avoidance

Small target region: 0.72 times smallNominal to 0.98 times smallNominal
Ambiguity band: 0.98 times smallNominal to 1.12 times smallNominal
Long target region: 1.12 times smallNominal to 0.94 times longNominal

- An intended Small Jump candidate passes only when Small succeeds and Long fails.
- An intended Long Jump candidate passes only when Long succeeds and Small fails.
- Tier 1 does not intentionally generate dual-reachable recovery platforms.
- No required target centre may sit inside the ambiguity band.

### 9.7 Basic Reachability and Crumble-Deadline Validation

The player is stationary while grounded, so an early or late tap on an unchanged static platform produces the same trajectory. Tier 1 timing tolerance therefore validates whether the jump remains legally available near the crumble deadline, not artificial trajectory changes from a nonexistent run-up.

1. Simulate the intended jump from the nominal grounded state with no Airborne Correction.
2. Simulate the non-intended jump from the same state with no Airborne Correction.
3. At collapseTime minus 160 ms, confirm the source still provides valid support or a valid jump state and the intended trajectory still lands.
4. At the final valid fixed step no later than supportLossTime plus 80 ms, simulate the coyote-time jump from the player's actual falling position and velocity.
5. Require valid top-surface swept collision and minimum overlap for every intended simulation.

minimumLandingOverlap = max(0.20 times playerCollisionWidth, 6 world units)

- No required validation simulation may use Airborne Correction.
- The intended jump must succeed nominally, at the 160 ms late-launch reserve and at the final coyote-time boundary.
- The wrong jump must fail at the nominal state.
- The target must be approached from above and must not require side or underside collision.
- Hard or fast landing never causes damage or death.

### 9.8 Candidate Rejection and Emergency Fallback

- Reject if neither jump succeeds, both jumps succeed, intended correction is required, overlap is insufficient, the route is blocked, the target lies in the ambiguity band, the late reserve fails or the coyote-boundary jump fails.
- Allow up to 16 normal candidate attempts.
- Retry by rerolling horizontal placement, width, vertical drop, route direction or intended jump type.
- If all attempts fail, create a static zero-angle emergency platform at the safest centre of the intended envelope with width max(nominalWidth times 1.25, 80).
- The emergency platform must still pass the same authoritative validation.

### 9.9 Pooling, Active World and Floating Origin

- Maintain approximately 2-3 screen heights above the player and 4-6 screen heights below.
- Generate a target buffer of roughly 6 screen heights below the camera.
- Recycle platforms after they leave the active range, finish crumble effects and can no longer be reached.
- Reset all physics, visuals, timers, metadata, audio and particles before returning a platform to the pool.
- Recentre the world when the player moves more than 5,000 world units from the current origin.
- Store total depth and score separately in double precision so recentering never changes progression.
