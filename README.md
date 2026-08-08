# SPLAT Physics — Runtime Physics, Gameplay & Animation Systems

## Overview

SPLAT Physics is a modular runtime physics, gameplay, and animation overhaul for **Cyberpunk 2077**. It provides extensive control over ragdoll behavior, character falls, directional pushes, bullet reactions, explosions, vehicle interactions, situational responses, and animation-to-physics transitions.

SPLAT is a public software project maintained through production debugging, automated regression testing, controlled releases, and feedback from an active user base. The project has shipped through more than **40 public releases** and has reached:

- **75,000+ total downloads**
- **32,000+ unique downloads**
- **750+ endorsements**

## Problem Statement

Default physics and animation behavior can produce:

- inconsistent ragdoll reactions
- limited control over push direction and magnitude
- unstable transitions between animation and physics
- repeated or conflicting hit reactions
- unrealistic falls, jolts, tumbles, and vehicle responses
- limited configuration for different gameplay styles

SPLAT addresses these problems through a configurable runtime system that routes physics behavior according to character state, hit context, selected mode, weapon type, environmental conditions, and user-defined settings.

## Core Capabilities

### Ragdoll and Fall Control

- Head and body fall systems
- Directional push handling
- Animation-to-ragdoll transitions
- Death and incapacitation routing
- Ground-contact and settle behavior
- Stair, slope, workspot, and movement-state handling

### Bullet and Impact Reactions

- Configurable bullet jolts
- Per-hit push control
- Body-part-aware reactions
- Weapon-specific behavior
- Suppression of unwanted vanilla impulses
- Separate handling for living, incapacitated, and dead NPCs

### Trip, Tumble, and Twitch Systems

- Situational trip behavior
- Directional tumble logic
- Configurable twitch reactions
- Randomized impulse ranges
- Runtime scheduling and delay controls

### Explosions and Vehicles

- Explosion force, lift, and radius controls
- Vehicle push handling
- Motorcycle fall behavior
- Vehicle occupant reaction protection
- Grenade exception handling
- Configurable weapon and explosion interactions

### Runtime Configuration

- Native Settings user interface
- Multiple independent gameplay modes
- Per-mode settings and visibility
- Persistent configuration and migration support
- Separate controls for head, body, jolts, explosions, vehicles, trip, tumble, settle, twitch, and randomization
- **2,377 menu setting definitions** validated by the current regression suite
- **1,675 non-UI settings** validated through declaration, bridge, and runtime usage

## Gameplay Modes

SPLAT supports multiple configurable modes:

- **Realism Custom** — full manual configuration
- **Realism Plus** — stronger realistic reactions
- **Clint Eastwood Old West** — exaggerated cinematic gun reactions
- **Arnold/Arcade** — intentionally extreme arcade-style physics

Each mode maintains its own settings rather than relying on one shared configuration.

## Architecture

SPLAT uses a modular, event-driven runtime architecture.

### Execution Flow

```text
Game Event
    ↓
Context and State Checks
    ↓
Physics Router
    ↓
Feature-Specific Logic
    ↓
Scheduled Ragdoll or Impulse Event
    ↓
Runtime Physics Response
```

Major systems are separated into focused REDscript modules, helper utilities, Native Settings schemas, and runtime configuration files. OnHit and OnDeath routes are validated independently so changes to one event pipeline cannot silently replace or reorder the other.

## Repository Structure

```text
.github/
└── workflows/
    └── ci.yml
scripts/
└── build-release.ps1
src/
├── archive/
│   └── pc/
│       └── mod/
│           └── rig.archive
├── bin/
│   └── x64/
│       └── plugins/
│           └── cyber_engine_tweaks/
│               └── mods/
│                   └── splat_native_settings/
└── r6/
    └── scripts/
        └── new Splat/
            ├── Features/
            ├── Helpers/
            └── Core REDscript systems
tests/
├── contracts/
├── run-all-tests.py
└── run-all-tests.ps1
```

### `src/archive`

Contains the custom rig archive used by the game.

### `src/bin`

Contains the Cyber Engine Tweaks and Native Settings implementation, including:

- Lua runtime code
- mode schemas
- section definitions
- shipped default settings
- interface visibility settings

### `src/r6`

Contains the REDscript gameplay implementation, including:

- physics routing
- head and body falls
- bullet jolts
- trip and tumble systems
- explosion and vehicle behavior
- randomization
- workspot and movement helpers
- death and incapacitation handling

### `tests`

Contains the local and CI merge gate. The PowerShell entry point invokes the Python 3 regression runner, which validates package structure, required files, gameplay pipeline contracts, complete settings wiring, menu visibility, obsolete controls, mode-selector ownership, and Trip debug defaults.

## Technical Highlights

- Event-driven runtime architecture
- Modular REDscript feature organization
- Lua and JSON-based configuration interface
- Per-mode configuration persistence and migrations
- Context-aware impulse routing
- Runtime scheduling and delayed execution
- Log-based debugging and issue reproduction
- Automated feature-pipeline and settings-wiring contracts
- Rollback-safe Mod Organizer 2 deployment
- Reproducible release ZIP and SHA-256 generation
- GitHub Issues, feature branches, worktrees, pull requests, CI gates, and controlled merges

## Development Workflow

Development is tracked and isolated through:

1. A GitHub Issue defines the defect or feature and its acceptance criteria.
2. A dedicated feature or fix branch is created in an isolated Git worktree.
3. The change is implemented and validated locally without mixing unrelated work.
4. The candidate files are deployed to Mod Organizer 2 with a rollback copy.
5. Exact-file and hash verification confirms that the intended build reached the test installation.
6. In-game acceptance testing confirms compilation and runtime behavior.
7. A pull request records the change, validation evidence, and affected systems.
8. GitHub Actions repeats the merge-gate suite and release-package build.
9. The pull request is merged through a controlled review and merge step.

This process keeps the game-tested build, repository history, CI results, and distributable package traceable to the same source state.

## CI and Release Engineering

GitHub Actions CI is implemented in [`.github/workflows/ci.yml`](.github/workflows/ci.yml) and runs on both pushes and pull requests targeting `main`.

The Windows CI job:

1. Checks out the repository.
2. Sets up **Python 3.12**.
3. Runs the complete regression gate through `./tests/run-all-tests.ps1`.
4. Builds a test release ZIP through `./scripts/build-release.ps1 -Version "ci-test"`.
5. Generates a SHA-256 checksum for the ZIP.
6. Uploads both the release ZIP and checksum as GitHub Actions workflow artifacts.

The confirmed current build, synchronized and merged through [PR #24](https://github.com/SunNight5656/Physics-Gameplay-and-Animation-Systems/pull/24), reports:

- **8/8 automated regression groups passing**
- **50/50 feature-pipeline contracts passing**
- **2,377 menu settings validated**
- **1,675 non-UI settings validated through declaration, bridge, and runtime usage**

The regression gate validates the current feature pipelines rather than relying on historical whole-file call counts. It covers OnHit, OnDeath, Arcade behavior, explosions, vehicles, Injury Shock, Bullet Jolts, workspots, menu lifecycle, package structure, and settings wiring.

### Release Artifacts and Deployment

Every CI run produces a testable ZIP and matching SHA-256 checksum as workflow artifacts. Local release candidates follow the same source layout used for the public Cyberpunk package.

Nexus Mods deployment is the next continuous-delivery extension. A Nexus GitHub Action or API integration can be added after release approval so an approved artifact is promoted without rebuilding it, but automated Nexus deployment is **not currently live**.

## Development Approach

SPLAT has been developed iteratively through testing, user feedback, log analysis, and repeated runtime debugging.

The development process includes:

- isolating systems into focused modules
- reproducing physics and animation failures
- tracing runtime event routes
- comparing expected and actual behavior
- testing changes in live gameplay
- preventing regressions across releases
- maintaining stable package structures
- publishing updates for an active user base

## Project Responsibilities

The project includes hands-on work in:

- system architecture
- gameplay and physics programming
- REDscript and Lua development
- JSON schema design
- Git branch and worktree management
- issue and pull-request workflows
- GitHub Actions CI
- release packaging and checksum verification
- rollback-safe deployment
- production debugging and log analysis
- regression and acceptance testing
- user support and technical documentation
- AI-assisted software engineering

## Dependencies

SPLAT currently uses:

- Cyber Engine Tweaks
- Native Settings UI
- redscript

The repository contains SPLAT’s own source and packaged project files. External dependencies must be installed separately by the user.

## Status

SPLAT remains under active development as a maintained public runtime system. Current work focuses on runtime stability, feature isolation, settings correctness, regression prevention, reproducible packaging, and extending the approved release artifact toward Nexus Mods delivery.
