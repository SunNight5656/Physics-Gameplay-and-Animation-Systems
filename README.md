# Runtime Physics and Gameplay Systems

## Overview

This project implements a modular, event-driven runtime system for controlling physics-driven animation behavior, including ragdoll transitions, impulse handling, and animation coordination.

The system was designed to improve realism, stability, and control beyond default engine behavior by introducing structured control over how characters respond to forces, collisions, and state transitions.

It has been developed and maintained across multiple iterations and is currently deployed in a production environment supporting approximately **19,000 users (42,000 downloads)**.

---

## Problem Statement

Default physics and animation systems often produce:

- inconsistent or unrealistic ragdoll behavior  
- poor control over impulse direction and magnitude  
- unstable transitions between animation and physics states  

This project addresses those issues by introducing:

- controlled impulse routing  
- configurable timing and response behavior  
- modular overrides for specific gameplay scenarios  

The result is more predictable, realistic, and tunable physics-driven character behavior.

---

## Architecture

The system follows a modular, event-driven architecture.

### Core Design

- Event-driven runtime system  
- Feature-based modular structure  
- Centralized routing and scheduling  
- Configurable behavior through runtime settings  

### Structure

- **Features/** – independent behavior modules  
- **Helpers/** – shared utilities and state management  
- **Core systems** – routing, ragdoll control, and coordination  

### Execution Flow
