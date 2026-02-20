# Halo - Runtime Object Editor

Halo is a runtime tool for Godot that lets you select, inspect, and modify game objects while your game is running. Changes can be saved back to the editor.

## Getting Started

Halo is set up as an autoload. Once the plugin gets enabled, middle-click any object in your running game to select it.

## Tools

When you select an object, a circular menu appears with these tools:

| Tool | Description |
|------|-------------|
| **Move** | Drag to reposition the object. Hold **Shift** to lock movement to a single axis (horizontal or vertical). |
| **Rotate** | Drag to rotate the object. Hold **Shift** to snap to 90-degree increments. |
| **Inspector** | Opens a property panel to view and edit any exported property on the object. |
| **Copy** | Duplicates the selected object. The copy appears offset from the original. |
| **Disable** | Toggles the object's processing and dims its visibility. Useful for isolating behavior. |
| **Delete** | Removes the object from the scene. |

## Saving Modes

A checkbox in the corner of the screen controls whether changes are saved:

- **Saving Mode** (green): Changes are sent to the Godot editor and saved to the scene file.
- **Playground Mode** (red): Changes only persist during the current session. Scene reloads restore them, but nothing is saved to disk.

Hold **Alt** to temporarily enable saving mode. Release to return to playground mode.

## Undo/Redo

- **Undo**: `Ctrl+Z` (Windows/Linux) or `Cmd+Z` (Mac)
- **Redo**: `Ctrl+Y` or `Cmd+Y`

Undo/redo works for move, rotate, and inspector changes.

## Configuration

Create a `HaloConfig` resource to customize behavior:

```gdscript
var config = HaloConfig.new()
config.activate_key = MOUSE_BUTTON_MIDDLE
Halo.config = config
```

### Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `activate_key` | int | `MOUSE_BUTTON_MIDDLE` | Key or mouse button to activate Halo |
| `saving_key` | Key | `KEY_ALT` | Key to toggle saving mode |
| `ui_position` | Vector2 | `(100, 0)` | Position of the save mode checkbox |
| `undo_key` | Key | `KEY_Z` | Key for undo (with Ctrl/Cmd) |
| `redo_key` | Key | `KEY_Y` | Key for redo (with Ctrl/Cmd) |

## Adding Custom Tools

You can add your own tools to the Halo menu:

```gdscript
class_name MyTool extends HaloTool

func _init() -> void:
    name = "My Tool"
    description = "Does something cool"
    color = Color.PURPLE
    icon = icon_from_atlas(0, 0)  # x, y position in atlas

func start_interaction() -> void:
    var target = Halo.get_target()
    # Do something with target
    Halo.finish_previous_tool_interaction()
```

Register it in your game:

```gdscript
func _ready():
    Halo.add_tool(MyTool.new())
```

If you tool only needs to handle simple functionality, you can use this shortcut:

```gdscript
var button_handler = func() -> void:
    self._is_moving = not self._is_moving

var my_tool = HaloTool.new()
my_tool.name = "My custom tool"
my_tool.color = Color.BLUE_VIOLET
my_tool.icon = HaloTool.icon_from_atlas(2, 9)
my_tool.callback = button_handler
my_tool.filter_type = Slime

Halo.add_tool(my_tool)
```

## Development

See the [Development Guide](development.md) for architecture details, component descriptions, and future ideas.
