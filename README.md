# Physics-Gameplay-and-Animation-Systems

A Cyberpunk 2077 REDscript project focused on runtime physics, gameplay reaction systems, ragdoll behavior, animation-state handling, and event-driven behavior routing.

This repository reflects 600+ hours of iterative systems design, debugging, testing, and tuning across modular gameplay and physics features. The work emphasizes controllable runtime behavior, configurable reaction logic, clean event routing, and practical tooling for experimenting with animation and physics interactions in a live game environment.

## Scope

This project includes modular systems for:

- physics-driven reaction handling
- impact and impulse routing
- ragdoll and collapse behavior
- rebound, stumble, and tumble logic
- collision and post-impact body-state control
- workspot, movement-state, and stair-related helpers
- configurable runtime behavior through mod settings

## Technical focus

Key areas of work include:

- REDscript-based runtime systems
- modular feature architecture
- event-driven gameplay logic
- animation-state and movement-state coordination
- physics and reaction tuning
- debugging and refinement of real-time gameplay behavior

## Repository structure

### Core systems
- `DeathRouter.reds`
- `DeathImpulse.reds`
- `Ragdoll.reds`
- `OnHit.reds`
- `Types.reds`
- `ModSettings.reds`
- `VanillaImpulseKiller.reds`

### Feature modules
- `1 GlobalNewImpulse.reds`
- `2_Feature_HeadFalls.reds`
- `Features/3Jolt.reds`
- `Features/4 Keep Dead Body Collision.reds`
- `Features/8 Splat_Bump_TripAnimation.reds`
- `Features/9 Splat_Bump_LookAtBackup.reds`
- `Features/10 MoveNPCwithFeet.reds`
- `Features/ArcadeWeapons.reds`
- `Features/RAMP SCHEDULERS.reds`
- `Features/StealthUtils.reds`
- `Features/Tumble.reds`
- `Features/Twitch.reds`

### Supporting helpers
- `Helpers/Positions.reds`
- `Helpers/HelpersWalkingRunning.reds`
- `Helpers/Helpers2WorkspotsStairs.reds`
- `Helpers/WorkspotLast.reds`

## Requirements

This project is intended for Cyberpunk 2077 environments using REDscript-based runtime scripting.

Common dependencies may include:

- RED4ext
- redscript
- Codeware
- TweakXL
- ArchiveXL
- Mod Settings

## Installation

1. Install the required Cyberpunk 2077 scripting frameworks.
2. Place the repository's `.reds` files into the appropriate `r6/scripts` structure.
3. Keep the folder layout intact if you want the existing `Features/` and `Helpers/` organization preserved.
4. Launch the game and verify that the scripts compile successfully.
5. Configure supported options through Mod Settings where applicable.

## Project intent

This repository is maintained as a systems-development project focused on real-time gameplay behavior, runtime control, and modular feature design. It serves both as an active implementation project and as a technical body of work demonstrating iteration, debugging, tuning, and architecture decisions in a complex scripted game environment.
