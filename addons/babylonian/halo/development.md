# Halo - Development Guide

## Components

### Halo - Core

**`halo.gd`** - Main autoload and entry point. Manages target selection, tool activation, and coordinates all other components. Holds the tool list and processes active tool interactions each frame.

**`halo_controller.gd`** - Handles input for target selection. Converts screen clicks to world positions, finds objects by distance or physics query, and walks up the node tree to find the appropriate selectable parent. `TileMapLayer` nodes and Halo itself are excluded from target selection.

**`halo_ui_builder.gd`** - Builds the circular tool menu UI. Positions buttons in a circle around the target, shows the target's name, and only rebuilds when the button set changes.

**`halo_config.gd`** - Resource class holding all configuration options. Exported properties appear in the inspector when saved as a .tres file.

### Persistence

**`halo_persistence_manager.gd`** - Type-agnostic persistence orchestrator. Creates the save mode checkbox UI, handles hold-to-save (Alt key), manages undo/redo stacks of `HaloAction` objects, detects scene reloads, and re-applies saved changes. Delegates all action-specific logic to the action classes — no match/switch on action types.

**`halo_editor_bridge.gd`** - Editor-side debugger plugin (`@tool`). Receives messages from the running game, deserializes them into `HaloAction` objects via `._action_from_message()`, and calls `apply_to_editor()`. Maintains a node path mapping for dynamically created nodes.

### Actions (Command Pattern)

All actions live in `scripts/actions/` and extend `HaloAction` (RefCounted base class). Each action encapsulates both game-side and editor-side execution, plus serialization for the debugger bridge.

**`halo_action.gd`** - Base class defining the action interface: `apply()`, `inverse()`, `serialize()`, `apply_editor()`, `summary()`.

**`set_property_action.gd`** - Changes a single property on a node. Stores old and new values for undo/redo.

**`create_node_action.gd`** - Instantiates a node from a scene file.

**`delete_node_action.gd`** - Removes a node from the scene tree (without freeing it). Stores the removed node for undo re-insertion.

To add a new action type, create a new file extending `HaloAction`, implement the interface methods, and add one line to `from_message()`.

### Tools

All tools extend `HaloTool` (RefCounted base class).

**`halo_tool.gd`** - Base class providing button creation, icon loading from atlas, and the tool lifecycle (`start_interaction`, `interact`, `finish_interaction`).

**`move_tool.gd`** - Drag-based position editing with axis locking. Shows a guide line when locked to an axis.

**`rotate_tool.gd`** - Drag-based rotation with 90-degree snapping.

**`inspector_tool.gd`** - Opens a property inspector window. Takes snapshots before and after to detect changes for undo support.

**`copy_tool.gd`** - Instantiates a copy of the target's scene file.

**`delete_tool.gd`** - Removes the target from the scene tree (via persistence manager, which keeps the node alive for undo).

**`disable_tool.gd`** - Toggles processing and dims visibility. Tracks disabled nodes to restore state.

## Data Flow

```
1) User clicks object
2) HaloController._input() --> queries target
3) Halo.set_target() --> attaches UI via RemoteTransform2D
4) User clicks tool button
5) HaloTool._on_click() --> start_interaction()
6) Tool modifies target properties
7) HaloTool.finish_interaction()
8) Halo.persistence.set_property(node, property)
	8a) Creates SetPropertyAction, pushes to undo stack
	8b) If saving mode: action.serialize() --> EngineDebugger.send_message()
	8c) Editor receives message --> _action_from_message() --> action.apply_to_editor()
```

## Known Issues

- Pressing `alt` (saving key) while the inspector window is open is not possible
- Scale of Halo can look weird (platformer1)
- Actions don't get checked on consistency, e.g. in the scenario:
	- Coin.position 1 changed without persisting
	- Coin.position 2 saved
	- Coin SaveTool (save all changes)
	- ==> Position 1 is the new state
	- Actions that depend on the scene tree could break entirely, as the target node might not exist in the engine 
- To undo a node creation you have to press CTRL+Z twice (position, creation)
- Undoing a node deletion resets the node's position back to initial not last
- Scene root can't be resolved correctly if the target scene isn't the active editor tab 

## Future Ideas

### Halo - General
- Multi-select multiple nodes
- Toast notification system for user feedback
- Move as MMB-Drag
- Secondary click options
- Undo/ Redo as tools
- Shortcuts for tools (CTRL+S for saving)

### Inspector
- Values get updated in real time
- Access the scene tree
- REPL like code execution interface
- Copy/paste property values between objects

### Persistence
- Visual diff showing original vs. modified state
- Export changes as a patch file
- Apply patches to different scenes
- Also persist ingame state / disabled state for nodes
- Per-object change history browser

### Integration
- Tilemap editing support
- 3D support (Node3D equivalent)


## Third-Party Software Used

The Halo object inspector window uses the [Object Inspector by Mansur Isaev](https://github.com/4d49/object-inspector), distributed under the MIT License. The license file can be found at `addons/babylonian/object-inspector/LICENSE.md`.
