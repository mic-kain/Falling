# Falling — Gameplay Rules (Tier 1)

Status: Locked for Tier 1 MVP implementation.

## 1. Product Summary

Falling is a fast, one-touch arcade game built around controlled panic. The player stands stationary on a platform that begins crumbling immediately after landing. They must read the next descending ledge and choose between a Small Jump and a Long Jump before the current platform collapses. As depth increases, vertical drops grow, horizontal gaps expand, platforms narrow, crumble timing accelerates and the descent becomes more intense.

The player is never damaged by impact. Hard or fast landings are always survivable. The only death condition is missing every valid platform and falling past the abyss boundary.

The MVP exists to answer one question: is choosing between a Small and Long Jump across narrowing, faster-crumbling platforms readable and satisfying enough to make players immediately want another run?

## 2. Design Pillars

| Pillar | Requirement |
|---|---|
| Constant pressure | Every platform is temporary. The player must act before the current ledge collapses. |
| Simple input | Left side means Small Jump. Right side means Long Jump. No grounded movement or directional steering. |
| Readable skill | The intended jump type must be visually distinguishable. Required jumps may be hard but never arbitrary. |
| Infinite escalation | Gap distance can grow indefinitely through increased vertical drop and modest velocity scaling. |
| Abyss-only failure | No health, fall damage, impact death, hazards or collision damage in Tier 1. |
| Immediate replay | The Game Over screen returns the player to a new run with one tap and under one second of delay. |

## 4. Core Gameplay Loop and Player States

Launch, Start Run, Land, Platform Crumbles, Read Gap, Small or Long Jump, Land and Repeat, Miss, Fall into Abyss, Game Over, Again.

| State | Tier 1 behaviour |
|---|---|
| Spawning | Player appears on the first platform. Input may be disabled for no more than 0.75 seconds. |
| Grounded | Player remains stationary. No walking, run-up, drift or grounded steering. Platform crumble timer advances. |
| Jumping | The chosen Small or Long trajectory runs under fixed-step physics. One Airborne Correction may be available. |
| Falling | The player is airborne and may still land. Falling alone is not death. |
| Landing | Swept collision confirms top-surface contact, resolves vertical movement and starts the new platform crumble timer. |
| Paused | Physics, crumble timers, camera and gameplay input stop. Resume requires deliberate input. |
| Dead | The full player collider has crossed the abyss boundary without valid support or a landing collision. |

## 5. Controls

### 5.1 Touch Zones

- The full edge-to-edge gameplay view is divided at its horizontal midpoint.
- Touch x less than 50% of gameplay width triggers Small Jump or Small Airborne Correction.
- Touch x at or beyond 50% of gameplay width triggers Long Jump or Long Airborne Correction.
- A touch exactly on the centreline is treated as the right-side action.
- Gameplay zones extend beneath notches, the Dynamic Island and Home indicator; HUD controls remain inside safe areas.
- Jump input is captured in SpriteKit through touchesBegan and triggers on touch-down, not release.
- The initial touch position determines the action. Finger movement after touch-down does not change it.
- A touch beginning on an enabled UI control is consumed by that control and never triggers gameplay.

### 5.2 Grounded Behaviour

- The player is completely stationary while grounded.
- There is no automatic movement, run-up, drift, swiping or manual direction selection.
- The route direction is determined by generated platform placement and the character automatically faces that direction.
- Waiting on an intact platform does not alter launch position or launch velocity.

### 5.3 Base Jump Physics

| Parameter | Small Jump | Long Jump |
|---|---|---|
| Base horizontal velocity | 260 world units/s | 390 world units/s |
| Base vertical velocity | -420 world units/s | -500 world units/s |
| Approximate apex time at depth 0 | 0.35 s | 0.42 s |
| Approximate maximum height at depth 0 | 74 world units | 104 world units |
| Launch input lockout | 80 ms | 100 ms |

Gravity is fixed at 1,200 world units per second squared. Maximum falling velocity begins at 1,450 world units/s and scales with depth. The final travel distance is not fixed; it depends on vertical drop, airtime and depth-scaled velocity.

### 5.4 Input Buffering and Edge Cases

- Only one primary gameplay touch is active at a time. The first touch timestamp wins; identical timestamps favour the right-side action.
- Holding a finger does not charge, repeat or extend a jump. The finger must be released before it can produce another input.
- No double jump exists.
- One next-jump input may be buffered within 120 ms of a predicted valid landing. Landing-buffer input has priority over Airborne Correction.
- Buffered input triggers only after at least 50 ms of confirmed grounded contact and no later than 80 ms after landing.
- Inputs during the initial launch lockout are ignored rather than queued as corrections.
- An 80 ms coyote-time window allows a jump immediately after support is lost through edge departure or complete platform collapse.
- Input timing windows are measured in elapsed seconds, never frame counts.

## 6. Tier 1 Airborne Correction

Airborne Correction is a locked Tier 1 recovery and skill-expression mechanic. It is never part of the required reachable envelope and no required platform may depend on it.

- One additional valid tap may be used per jump after the launch lockout and during the first 65% of predicted airtime.
- Left-side airborne tap requests Small Correction; right-side airborne tap requests Long Correction.
- The correction changes horizontal velocity only. It never changes vertical velocity, gravity, jump height, facing or direction.
- The impulse is always applied in the existing horizontal travel direction; touch side selects strength, not direction.
- Small Correction impulse equals the current depth-scaled Small Jump horizontal velocity multiplied by 0.135.
- Long Correction impulse equals the current depth-scaled Long Jump horizontal velocity multiplied by 0.155.
- Corrected horizontal velocity is capped at 117% of the original jump type's horizontal velocity.
- Added horizontal travel is capped at 8% of the original predicted nominal jump distance.
- The correction resets only after a valid landing. It does not reset during a continuous fall or after passing a platform.
- There is no per-run limit, energy meter or cooldown between different jumps.

appliedImpulse = min(requestedImpulse, maximumAdditionalDistance divided by remainingPredictedAirtime, velocityCapRemaining)

A corrected trajectory is integrated through the same 1/120-second simulation and the same swept collision detection as every other jump. The correction never snaps the player onto a platform.

## 10. Abyss-Only Death and Failure Flow

The player dies only when the full player collider passes below the camera-relative abyss boundary after missing all valid platforms.

abyssDeathOffset = 1.35 multiplied by visibleGameplayHeight, measured below camera centre

- No health, lives, damage, fall damage, impact damage, stun or hazard death exists.
- A valid swept landing always survives, regardless of downward velocity.
- The player remains visibly falling for approximately 0.6 to 1.2 seconds after a miss before Game Over.
- There is no bottom impact. The player disappears into darkness.
- Game Over appears within 0.25 seconds of confirmed abyss death.
