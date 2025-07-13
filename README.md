# Babylonian Programming / Godot

An implementation of the [Babylonian Programming System][babylonian_programming] for [Godot][godot].

## How to install

Currently, Babylonian/G can be installed as a Godot plugin using one of two methods.

### 1. Installing Babylonian/G in a new project

Clone this repository and remove anything outside `addons/babylonian` that you don't need.

### 2. Installing Babylonian/G in an existing project

1. Clone this repository somewhere and copy the `addons/babylonian` directory into your project. If needed, create the `addons` directory in your project first.
2. Open the plugin list via `Project > Project Settings... > Plugins` and then click on `enable` next to the `babylonian` plugin.

## Demo

https://github.com/hpi-swa-lab/babylonian-programming-godot/assets/41512063/44eb4ce2-2119-400b-b367-f0939ab6fe97

## How to use

The system contains two parts: probes and examples. The former can be used to visualize the values of expressions in real-time. The latter allows recreation of specific game scenarios.

We have also included a simple platformer game in `platformer.tscn` which can be used to experiment with probes and examples, but is not essential to the functionality of the plugin.

### Probes

To attach a probe to any expression, simply wrap the expression with either `B.probe(...)` or `B.game_probe(...)`. Use the former if you only want to see the probe next to the line of code in the editor. Use the latter if you also want to see the probe directly in the game. Alternatively, choose _Wrap in probe_ from the context menu after selecting the expression you want to probe (Currently, this method only supports `B.probe` and not `B.game_probe`).

The probe itself also always returns the expression that it is wrapping, therefore you can also use probes inside if conditions, for example. Probes can be created or modified while a game is running in the background, which is very useful for testing or debugging purposes.

Additionaly, you can also create multiple widgets for a single probe by passing a second parameter called `group`. For each distinct value that is passed as the `group`, a new widget is created which only shows values passed with the `group`. This is useful when you have multiple instances of a class and still want to probe an expression: you can simply pass `self` as the `group`. Then, a widget is created for each instance of the class and each widget only shows the value for the corresponding instance. As a special case, if you pass a `Node2D` as the `group` and you use `B.game_probe`, the in-game widgets will be attached to their corresponding nodes and will follow them when they move.

We currently support probes for colors, floats, strings and vectors. We automatically try to convert other data type to the ones that are supported, so most other data types can also be visualized, even though they may not have additional features characteristic to that data type.

### Examples

1. Start the game.
2. In the top right, you'll find a UI for creating and restoring examples.
3. Prepare your example (e. g. walk to a spot which you want to examine).
4. Choose an example mode:
   | Mode                       | Explanation                                                                                |
   | -------------------------- | ------------------------------------------------------------------------------------------ |
   | Snapshot only              | Captures the state of the entire game                                                      |
   | Input Recording only       | Starts capturing all user input and stops after you press _Stop recording_ in the top left |
   | Snapshot & Input Recording | Takes a snapshot first, then immediately starts Input Recording                            |
4. Press _Start example_ or <kbd>Ctrl</kbd>+<kbd>S</kbd>.
5. If your selected mode includes Input Recording:
    - Perform the user input (e. g. jump around).
    - Press _Stop recording_ or <kbd>Ctrl</kbd>+<kbd>S</kbd>.
7. The new example appears below the UI:
    ![example slot](https://github.com/hpi-swa-lab/babylonian-programming-godot/assets/41512063/a23d0d37-d06a-44b9-b9f7-b8cd78f0594b)
    - The number (_1_) indicates the index of the example _slot_.
    - The parentheses indicate the mode of the example: _S_ stands for Snapshot and _R_ for Input Recording.
    - The _[last]_ brackets show the last used slot.
    - The input box contains the name of the example (_Example 1_). You can rename the example by typing in the input box. After you renamed the example, press <kbd>Esc</kbd> to prevent further user input from reaching the input box.
    - The _Loop_ checkbox is used when restoring the example, see below. It is only present for examples that include an input recording.
    - The _Save_ button is used to store the example on disk. When you click it, a file save dialog opens.
    - The _Restore_ button is used to apply the example.
        - If the example includes a snapshot, the game state it captured will be restored.
        - If the example includes an input recording, it will be played back.
        - If _Loop_ is enabled, the example will be restored again after the playback of the input recording has completed. This will repeat indefinitely.
        - Playback of an input recording (looped or not) can be stopped using the _Stop playback_ button in the top left.
    - The _Delete_ button is used to remove the example slot. This will not delete an example from disk.
8. You can now restore the example using the _Restore_ button (see above). You can also use a keyboard shortcut. First, press <kbd>Ctrl</kbd>+<kbd>R</kbd>, then
   - <kbd>Ctrl</kbd>+<kbd>1</kbd> through <kbd>Ctrl</kbd>+<kbd>9</kbd> to load the example slot with the corresponding index. <kbd>Ctrl</kbd>+<kbd>0</kbd> loads example slot 10. More than 10 example slots are not supported using this keyboard shortcut.
   - <kbd>Ctrl</kbd>+<kbd>R</kbd> to load the example slot annotated with _[last]_.

Examples can be saved to disk (see above). They will be saved as JSON files in the `examples` directory in the top-level of your project.
- The checkbox _Save next example to disk_ has the same effect as immediately pressing the _Save_ button after a new example has been created.
- Examples can be loaded from disk using the _Load from disk_ button. It opens a file picker dialog and loads the selected example into a new example slot.

## Limitations

- Multiple probes per line of code are unsupported. This also includes line continuations using a `\` at the end of the line.
- It is currently not possible to serialize Godot's [`RID`](https://docs.godotengine.org/en/stable/classes/class_rid.html), which can break the snapshotting/example system on certain games.
- After stopping the playback of an input recording, any keys pressed by the recording at this time remain pressed. You have to press the keys manually to release them.
- Sometimes, the UI for the examples system is scaled inappropriately.

## Related Projects

- [Godot][godot]
- [Babylonian Programming System][babylonian_programming]
- [Babylonian/S][babylonian_s]
- [Babylonian/JS][babylonian_js]
- [Polyglot Babylonian Programming in VSC][babylonian_vsc]

[godot]: https://godotengine.org/
[babylonian_programming]: https://doi.org/10.22152/programming-journal.org/2019/3/9
[babylonian_s]: https://github.com/hpi-swa-lab/babylonian-programming-smalltalk
[babylonian_js]: https://lively-kernel.org/lively4/lively4-core/start.html?load=https://lively-kernel.org/lively4/lively4-core/src/babylonian-programming-editor/demos/index.md
[babylonian_vsc]: https://github.com/hpi-swa/polyglot-live-programming

# Babylonian Programming / Godot - Halo

A Halo System for Godot based on the Squeak/Smalltalk Halo System.

## How to Install

The Halo is part of **Babylonian Programming / Godot**. 

## How to Use / Features

### Overview

This addon adds an in-game halo, similar to the one in Squeak/Smalltalk, to your Godot game. You can perform basic and advanced manipulation as well as inspection using this halo.

### Controls

Click on any game object using the **[Middle Mouse Button]** to select it and spawn a halo around it. 

By holding **[Shift]** during selection, the parent of the currently selected object in the game tree is selected. By holding **[Ctrl]**, the selection is limited to the children of the currently selected object in the game tree.

Use **[Ctrl] + [Z]** and **[Ctrl] + [Y]** to navigate through the selection history.

Normally, the halo follows the selected object. This behavior can be toggled by pressing **[F2]**. The halo will switch between following the object and staying still. With **[F3]**, the halo can be placed at the center of the screen. Pressing **[F2]** again will make the halo follow the object.

### Displayed Information

Around the halo, some information is displayed. On the left, you can see the rotation angle of the selected object. On the right, the object's global position is displayed. 

Below the halo, the object's name as well as its depth in the game tree (the root has depth 0) can be seen.

### Halo Buttons

#### Translation

The three arrow buttons enable you to move the object across the plane, across the X-axis, and across the Y-axis.

#### Rotation

The curved arrow button allows you to rotate the object. The horizontal rectangle button resets the object's rotation to 0 degrees.

#### Duplication

The plus button copies the object and places the duplicate next to the original object.

#### Property Inspection

The magnifying glass button opens a property inspector displaying all properties of the selected object. You can view and change the properties. Each property has two buttons labeled **P** and **C**. The **P** button spawns a probe window containing a **Babylonian/G Probe**. The **C** button copies the property's value to the clipboard.

#### Game Tree Navigation

Pressing the network button will toggle lines that indicate the object's position in the game tree. An orange line points toward the object's parent in the game tree. Blue lines point toward children.

Pressing the list button opens a window containing a list of all children of the currently selected object. You can use this list to select any of the children.

#### Object Deletion

Pressing the red cross button deletes the selected object.

### Extensibility

You can add custom buttons to the Halo. The following example demonstrates this by adding a button that toggles the visibility of an `AnimatedSprite2D`. You need to perform the following steps:

##### 1. Define a callback that handles a button click

```js
var button_handler = func(target: CanvasItem) -> void:
    target.visible = not target.visible
```

##### 2. Define a `Texture2D` for the button

Here we are using a texture from a texture atlas.

```js
var atlas: Texture2D = load("res://path/to/texture/atlas/file.png")
var region: Rect2 = Rect2(Vector2(100, 450), Vector2(50, 50))
var texture: Texture2D = AtlasTexture.new()
texture.atlas = atlas
texture.region = region
```

##### 3. Define what node types are affected

```js
var node_types: Array[String] = ["AnimatedSprite2D"]
```

You can add as many node types as you want. By using an empty list, all node types will be affected.

##### 4. Define the button’s color

```js
var color_modulation: Color = Color.ORANGE
```

##### 5. Add the button using the `button_manager`

```js
HaloDispatcher.button_manager.add_button(
    texture, 
    button_handler,
    node_types,
    color_modulation
)
```

This will add a button to the Halo of all `AnimatedSprite2D` nodes.

The `node_types` default to `[]`, and the `color_modulation` defaults to `Color.WHITE`.

## Limitations

- There is currently no 3D support. The halo only works in 2D games.
- Changes to the scene made with the halo cannot be exported yet.
- It is not possible to select multiple objects at once.
- It is difficult to select objects that are out of the camera’s FOV. An independent camera could solve this problem.

## Third-Party Software Used

The Halo object inspector window uses the [Object Inspector by Mansur Isaev](https://github.com/4d49/object-inspector), distributed under the MIT License. The license file can be found at `addons/babylonian/object-inspector/LICENSE.md`.
