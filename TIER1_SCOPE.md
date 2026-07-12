# Falling — Tier 1 Scope (MVP)

Status: Locked for Tier 1 MVP implementation.

## 3. Tier 1 MVP Scope

Tier 1 is the complete, shippable MVP. It includes only the systems required to test the core loop as a polished native iOS game.

- Option A two-zone controls: left-side Small Jump and right-side Long Jump.
- Stationary grounded player model with immediate touch-down input.
- One optional Airborne Correction per jump.
- Tier 1 procedural generation using standard static crumbling platforms only.
- Infinite vertical-drop and jump-range scaling.
- Progressively narrowing platforms and accelerating crumble timing.
- Authoritative reachability, ambiguity and crumble-deadline validation.
- Abyss-only death condition.
- Distance scoring, local personal best, minimal HUD, tutorial, pause and Game Over UI.
- Minimal coherent visual style, audio, haptics and analytics.
- Object pooling, floating origin, lifecycle pause handling and iPhone performance targets.

### Explicitly Deferred

- All Tier 2 procedural generation: angled platforms, special platform classes, moving platforms, wind, moving hazards, branching routes, optional risk/reward routes, difficulty budgets and the full ten-stage validation pipeline.
- Cosmetics, character skins, unlockable environments and progression systems.
- Monetisation, advertisements, subscriptions, paid continues or revives.
- Leaderboards, Game Center, achievements, daily challenges, social sharing or ghost runs.
- Android, iPad-specific layouts, macOS, console or any cross-platform engine work.
- Enemies, combat, health, checkpoints, story, multiple modes or power-ups.

## 11. Scoring, HUD and UI

### 11.1 Scoring

- Primary score is deepest vertical distance reached, displayed as whole metres.
- displayedMetres = floor(totalDepthDescended divided by 10). The conversion is presentation-only.
- Score never decreases during a run and is unaffected by floating-origin recentering.
- One local personal best persists between app launches.
- When the previous best is exceeded, show NEW BEST for 0.8 seconds and trigger one success haptic.
- Tier 1 has no combos, coins, bonuses, grades, multipliers or platform-completion points.

### 11.2 Gameplay HUD

| Element | Requirement |
|---|---|
| Current depth | Top centre inside safe area; format "327 m"; update visual text no more than 10 times per second. |
| Best depth | Secondary text near current depth; format "BEST 512 m". |
| Pause | Top-right safe-area region; minimum 44 x 44 point touch target; the only HUD item that intercepts gameplay touch. |

### 11.3 Main Menu

- Game title: FALLING.
- Best score.
- Primary Play button.
- Secondary Settings control.
- No account, profile, news, store, social buttons or daily rewards.

### 11.4 Pause Screen

- Resume.
- Restart Run.
- Settings.
- Return to Main Menu.
- Restart and Main Menu clear stale touches and do not count as abyss deaths in analytics.

### 11.5 Game Over Screen

- Display YOU FELL, run distance, best distance and NEW BEST when applicable.
- Primary button label: AGAIN.
- One tap starts a new run with no confirmation or countdown.
- Target time from AGAIN tap to player control is under one second.
- Secondary Main Menu control.
- No revive, advertisement, share prompt, leaderboard rank, currency or rating request.

## 12. Tutorial and Settings

### 12.1 First-Run Tutorial

- First platform displays a translucent left-half prompt: SMALL JUMP, TAP LEFT. The next platform requires Small Jump.
- Second platform displays a translucent right-half prompt: LONG JUMP, TAP RIGHT. The next platform requires Long Jump.
- Both tutorial platforms use at least a 7-second crumble timer.
- After both jump types are completed successfully, remove the overlays and save a local completion flag.
- If the player dies before completion, restart the tutorial sequence.

### 12.2 Minimal Settings

- Sound Effects on/off.
- Music on/off.
- Haptics on/off.
- Reduced Motion on/off.
- Reset Tutorial.
- Privacy and analytics information where required.
- Reduced Motion lowers camera shake, zoom pulses, parallax and particle density but never changes physics, timing or difficulty.

## 13. Minimal Art Direction

- Minimalist, high-contrast silhouette style with a clear top landing surface and readable crumble states.
- Background gradually darkens from muted grey or desaturated blue toward near-black with depth.
- Platforms use simple rock-like rectangular silhouettes with slight visual irregularity and accurate collision width.
- Player uses a compact high-contrast silhouette or geometric figure with grounded, jump, fall and landing poses.
- Camera uses smooth vertical follow, downward look-ahead, modest depth-scaled zoom and small landing shake.
- No multiple environments, skins, story art, enemies, complex lighting, weather or 3D assets.

## 14. Minimal Audio and Haptics

| Event | MVP feedback |
|---|---|
| Small Jump | Short light launch sound; optional very light transient. |
| Long Jump | Stronger, clearly distinct launch sound and light transient. |
| Airborne Correction | Subtle air-movement sound, trail pulse and optional light transient. |
| Landing | Rock impact and light/medium haptic; intensity may scale with landing velocity but never implies damage. |
| Crumble progression | Early crack cues, stronger late warning, one haptic near the final 15%. |
| Full collapse | Distinct rock break and medium impact. |
| New Best | Short positive sound and success haptic. |
| Abyss death | Descending wind or low tone and soft failure haptic; no bottom impact. |

The MVP includes one minimal looping ambient track or soundscape with modest depth-based intensity. Music and sound effects are independently disableable. Audio and haptics pause or attenuate when the app becomes inactive.

## 15. Analytics and Success Metrics

Instrumentation must determine whether the loop is understandable, fair and replayable without requiring an account or affecting gameplay performance.

| Event | Required properties |
|---|---|
| run_started | runID, runSeed, tutorialComplete, appVersion, device category, refresh category |
| jump_started | runID, depth, jumpType, source/target widths, gap, vertical drop, crumble remaining, coyote use |
| airborne_correction_used | runID, depth, base jump type, correction type, applied impulse, remaining airtime |
| landing_completed | runID, depth, jumpType, overlap, landing velocity, correction used |
| jump_missed | runID, depth, actual jump, intended jump, gap, vertical drop, target width, miss direction |
| platform_collapsed_while_grounded | runID, depth, crumble duration, grounded time, coyote attempted/succeeded |
| run_ended | final depth, prior best, new best, duration, platforms landed, jump counts, correction count, end source |
| restart_selected | time on Game Over, previous depth, new best |

### 15.1 Core Evaluation Metrics

- Tutorial completion without external explanation.
- Immediate Again rate within 10 seconds of abyss death.
- Median runs per session and percentage of sessions with three or more runs.
- Median depth, best depth and improvement across repeated runs.
- Wrong-jump choice rate by intended Small and Long targets.
- Miss classification: short, overshoot, left, right, side pass or unknown.
- Decision time as a share of crumble duration, final-25% launches and coyote attempts.
- Generator candidate rejection rate and emergency-platform frequency by depth.
- Crash-free sessions, sustained frame rate and bounded memory use.

| Initial diagnostic threshold | Target |
|---|---|
| Tutorial completion | at least 80% |
| Immediate Again after abyss death | at least 60% |
| Median runs per session | at least 3 |
| Wrong-jump share after tutorial | under 35% |
| Impossible accepted required platforms | 0 |
| Sustained memory growth | None |
| Baseline frame rate | Stable 60 fps |

These are diagnostic playtest thresholds, not commercial promises. A miss should feel like an "I nearly had it" moment, not evidence that the game generated something unfair.

## 16. MVP Completion and Shipping Gate

- Controls match the locked two-zone behaviour and the player remains stationary while grounded.
- Airborne Correction behaves identically at 60 Hz and 120 Hz rendering and never alters vertical velocity.
- All accepted Tier 1 platforms pass nominal, wrong-jump, late-reserve and coyote-boundary validation without correction.
- The authoritative collider shrink threshold is 85%; no 65% collider-shrink rule remains in code or documentation.
- Swept collision prevents tunnelling at high fall speeds.
- Abyss crossing is the only death condition.
- Tier 1 generation runs indefinitely with bounded node count and stable floating-origin behaviour.
- At least 25,000 automated required-platform transitions pass across early, mid, deep and extreme simulated depth.
- Game Over to restart is under one second in normal conditions.
- Lifecycle interruptions pause safely and never cause unavoidable death.
- Best score, settings and tutorial state persist locally.
- Observed playtests demonstrate that the controls are understood, difficulty escalation is visible and players voluntarily replay.

## 18. Locked MVP Validation Question

Is the Small-versus-Long jump decision, under relentless crumbling pressure and infinite downward escalation, strong enough on its own to create an immediate Again response? If the answer is not clearly positive, Tier 2 systems must not be added to disguise weaknesses in the core mechanic.
