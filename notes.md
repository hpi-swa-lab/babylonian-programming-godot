# Notes

## Select Feature (22.04.2025)

Observations while testing the [select feature](https://godotengine.org/article/dev-snapshot-godot-4-5-dev-1/#allow-selecting-multiple-remote-nodes-at-runtime):
- This feature only works in debug builds.
- When there is a Camera2D the select tool can only select this camera.
	- That is because the cameras viewport is placed above all other nodes.
	- This problem can be solved by disableing the cameras visibility in the scene tree.
- In 2D mode one can select multiple nodes using Shift-Click but selecting only by mouse does not seem to be possible.
- In 3D mode there is a selection frame but it does not select any 2D Nodes
- In 2D mode there is also a selection frame but it only works when the selection starts on an empty spot.
	- The problem here is that in most 2D games there is a baxkgroundlayer (eg a tilemap)
	- Therefore nor selection frame possible here
- Via the "selection_changed" signal an EditorPlugin can determine which node was selected.
	- But this only works if it was selected in the editor window.
