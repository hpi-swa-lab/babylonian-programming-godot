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
    ![image](https://hackmd.io/_uploads/SyfWEySo6.png)
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
