# Physics-Gameplay-and-Animation-Systems

A Cyberpunk 2077 REDscript project focused on runtime physics behavior, gameplay reactions, animation-state handling, and event-driven systems design.

This repository reflects 600+ hours of iterative implementation, debugging, testing, and tuning across modular gameplay and physics features. The project emphasizes controllable runtime behavior, configurable reaction logic, clean event routing, and practical systems development inside a live game environment.

## Overview

This repository contains modular REDscript systems for:

- physics-driven reaction handling
- impact and impulse routing
- ragdoll and body-state behavior
- rebound, stumble, trip, and tumble logic
- collision handling and post-impact control
- movement-state, workspot, and stair-related helpers
- configurable runtime behavior through Mod Settings

## Technical Focus

Key areas of work include:

- REDscript-based runtime systems
- modular feature architecture
- event-driven gameplay logic
- animation-state and movement-state coordination
- physics and reaction tuning
- debugging and refinement of real-time gameplay behavior

## Repository Structure

### Core Systems
- `Router.reds`
- `Impulse.reds`
- `Ragdoll.reds`
- `OnHit.reds`
- `Types.reds`
- `ModSettings.reds`
- `VanillaImpulseKiller.reds`
- `GlobalNewImpulse.reds`
- `HeadFalls.reds`

### Feature Modules
Located in `Features/`, these files cover focused gameplay and physics behaviors such as:

- jolt and twitch systems
- trip and look-at backup behavior
- movement with feet
- collision-related features
- tumble logic
- utility and scheduler support
- arcade and weapon-related behaviors

### Supporting Helpers
Located in `Helpers/`, these files support:

- position handling
- walking and running state helpers
- workspot and stair-related helpers
- routing and shared utility behavior

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
2. Place the repository’s `.reds` files into the appropriate `r6/scripts` structure.
3. Keep the folder layout intact if you want the existing `Features/` and `Helpers/` organization preserved.
4. Launch the game and verify that the scripts compile successfully.
5. Configure supported options through Mod Settings where applicable.

## Design Approach

This project is organized around modular runtime systems rather than a single monolithic script. The goal is to make feature behavior easier to isolate, test, tune, and extend.

The broader design priorities include:

- clean separation of feature logic
- configurable runtime controls
- practical iteration inside a scripted game environment
- reusable helper systems for shared state and positioning logic
- maintainable event routing across multiple gameplay behaviors

## Project Intent

This repository is maintained as a systems-development project focused on runtime control, gameplay behavior design, and modular feature implementation. It serves both as an active technical project and as a body of work demonstrating architecture decisions, experimentation, debugging, and iterative refinement in a complex scripted environment.

## Notes

Behavior may vary depending on:

- game version
- framework versions
- installed gameplay or AI mods
- overlapping wrapped methods
- script load order

If multiple mods alter the same runtime systems, compatibility issues may occur.

## License

Add your preferred license or usage terms here.
