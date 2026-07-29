# SPLAT Physics — Runtime Physics and Gameplay Systems

## Overview

SPLAT Physics is a modular physics and gameplay overhaul for **Cyberpunk 2077**. It provides extensive control over ragdoll behavior, character falls, directional impulses, bullet reactions, explosions, vehicle interactions, situational responses, and animation-to-physics transitions.

The project has grown through more than **40 public releases** and has reached approximately **70,000 total downloads** and **30,000 unique downloads**.

SPLAT is both a production mod and an ongoing software-engineering project focused on runtime debugging, configurable system design, release management, regression prevention, and automated delivery.

---

## Problem Statement

Default physics and animation behavior can produce:

* inconsistent ragdoll reactions
* limited control over impulse direction and magnitude
* unstable transitions between animation and physics
* repeated or conflicting hit reactions
* unrealistic falls, jolts, tumbles, and vehicle responses
* limited configuration for different gameplay styles

SPLAT addresses these problems through a configurable runtime system that routes physics behavior according to character state, hit context, selected mode, weapon type, environmental conditions, and user-defined settings.

---

## Core Capabilities

### Ragdoll and Fall Control

* Head and body fall systems
* Directional impulse handling
* Animation-to-ragdoll transitions
* Death and incapacitation routing
* Ground-contact and settle behavior
* Stair, slope, workspot, and movement-state handling

### Bullet and Impact Reactions

* Configurable bullet jolts
* Per-hit impulse control
* Body-part-aware reactions
* Weapon-specific behavior
* Suppression of unwanted vanilla impulses
* Separate handling for living, incapacitated, and dead NPCs

### Trip, Tumble, and Twitch Systems

* Situational trip behavior
* Directional tumble logic
* Configurable twitch reactions
* Randomized impulse ranges
* Runtime scheduling and delay controls

### Explosions and Vehicles

* Explosion force, lift, and radius controls
* Vehicle impulse handling
* Motorcycle fall behavior
* Vehicle occupant reaction protection
* Grenade exception handling
* Configurable weapon and explosion interactions

### Runtime Configuration

* Native Settings user interface
* Multiple independent gameplay modes
* Per-mode settings and visibility
* Persistent default configuration
* More than 200 adjustable parameters
* Separate settings for head, body, jolts, explosions, vehicles, trip, tumble, settle, twitch, and randomization

---

## Gameplay Modes

SPLAT supports multiple configurable modes:

* **Realism Custom** — full manual configuration
* **Realism Plus** — stronger realistic reactions
* **Clint Eastwood / Dirty Harry** — exaggerated cinematic gun reactions
* **Arnold Arcade** — intentionally extreme arcade-style physics

Each mode maintains its own settings rather than relying on one shared configuration.

---

## Architecture

SPLAT uses a modular, event-driven architecture.

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

Major systems are separated into focused REDscript modules, helper utilities, Native Settings schemas, and runtime configuration files.

---

## Repository Structure

```text
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
```

### `src/archive`

Contains the custom rig archive used by the game.

### `src/bin`

Contains the Cyber Engine Tweaks and Native Settings implementation, including:

* Lua runtime code
* mode schemas
* section definitions
* shipped default settings
* interface visibility settings

### `src/r6`

Contains the REDscript gameplay implementation, including:

* physics routing
* head and body falls
* bullet jolts
* trip and tumble systems
* explosion and vehicle behavior
* randomization
* workspot and movement helpers
* death and incapacitation handling

---

## Technical Highlights

* Event-driven runtime architecture
* Modular REDscript feature organization
* Lua and JSON-based configuration interface
* More than 200 configurable parameters
* Per-mode configuration persistence
* Context-aware impulse routing
* Runtime scheduling and delayed execution
* Log-based debugging and issue reproduction
* Regression testing across frequent public releases
* Installable Cyberpunk package structure
* Git-based version control and release history

---

## Development and Release Engineering

The repository is being expanded into a complete CI/CD portfolio project.

Planned delivery workflow:

```text
Source Change
    ↓
Repository Validation
    ↓
Configuration and Structure Checks
    ↓
Automated Release Packaging
    ↓
Version and Checksum Generation
    ↓
GitHub Release Artifact
    ↓
Approved Nexus Mods Deployment
```

Planned DevOps components include:

* automated repository validation
* PowerShell and Linux build scripts
* GitHub Actions
* Jenkins
* release ZIP generation
* version verification
* SHA-256 checksums
* secrets and dependency scanning
* release approval controls
* rollback documentation
* deployment verification

---

## Development Approach

SPLAT has been developed iteratively through testing, user feedback, log analysis, and repeated runtime debugging.

The development process includes:

* isolating systems into focused modules
* reproducing physics and animation failures
* tracing runtime event routes
* comparing expected and actual behavior
* testing changes in live gameplay
* preventing regressions across releases
* maintaining stable package structures
* publishing updates for an active user base

---

## Project Responsibilities

The project includes hands-on work in:

* system architecture
* gameplay and physics programming
* REDscript and Lua development
* JSON schema design
* Git and branch management
* release packaging
* production debugging
* log analysis
* regression testing
* user support
* technical documentation
* CI/CD development
* AI-assisted software engineering

---

## Dependencies

SPLAT currently uses:

* Cyber Engine Tweaks
* Native Settings UI
* redscript

The repository contains SPLAT’s own source and packaged project files. External dependencies must be installed separately by the user.

---

## Status

SPLAT remains under active development. Current work focuses on:

* stabilizing runtime physics routes
* expanding automated validation
* preventing configuration regressions
* improving release packaging
* documenting the full delivery pipeline
* converting the project into demonstrable DevOps and release-engineering experience
