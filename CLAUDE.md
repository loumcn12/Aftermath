# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Aftermath is a 3D first-person survival game developed in Godot 4.4 by Louis & Ehren for their Y13 Game Development Project. The game features multiple levels with objectives like collecting medpacks and managing nuclear facilities.

## Project Structure

### Core Architecture
- **Global State Management**: `scripts/globalscript.gd` manages cross-scene variables including mouse settings, stamina, health packs, mouse sensitivity, and current level
- **Main Scene Controller**: `scripts/main.gd` handles level 1 logic, building placement system, and pause menu functionality
- **Player Controller**: `scripts/player.gd` implements first-person movement, stamina system, health management, interaction system, and head bobbing

### Scene Organization
- `scenes/` - All Godot scene files (.tscn)
  - `scenes/buildings/` - Building prefabs organized by size (1x1, 2x1, 2x2, 3x1, 3x2, 3x3)
  - `scenes/main menu/` - Menu system scenes
- `scripts/` - All GDScript files (.gd)
- `assets/` - Game assets organized by category (audio, buildings, textures, etc.)

### Key Systems

#### Building System
The main scene uses a coordinate-based building placement system where buildings are randomly selected from pools organized by size categories and placed at predefined positions with specific rotations.

#### Player Systems
- **Movement**: WASD movement with sprint (Shift), crouch (Ctrl), and jump (Space)
- **Interaction**: Ray-casting based interaction system (E key) for health packs and uranium
- **Combat**: Simple punch-based combat (Left Mouse) against enemies
- **Stamina**: Dynamic stamina system affecting sprint and jump abilities
- **Health**: Health system with fall damage and healing via medpacks

#### Input Mapping
- WASD: Movement
- Shift: Sprint
- Ctrl: Crouch
- Space: Jump
- E: Interact
- I: Inventory
- H: Damage test
- R: Reset level
- Mouse: Camera control and combat

## Development Commands

Since this is a Godot project, development primarily happens within the Godot Editor. The project uses:
- **Project File**: `project.godot` (Godot 4.4, Forward Plus rendering)
- **Export Settings**: `export_presets.cfg` for building the game
- **Version**: Currently at 0.2.1

## Level Design

The game features multiple levels:
- **Level 1**: Collect 3 medpacks and return to bunker
- **Level 2**: Find nuclear fuel and restart nuclear plant

Each level has specific objective tracking implemented in the player controller's `_physics_process` method.

## Code Conventions

- Use GDScript for all game logic
- Follow Godot's node-based architecture
- Use `@onready` for node references
- Implement global variables through the `Globalscript` autoload
- Use groups for categorizing interactable objects ("health", "enemy", "uranium")
- Prefix private/internal methods with underscore (e.g., `_Damage`, `_physics_process`)