# halo_dispatcher.gd
extends Node2D

var _target_finder: TargetFinder
var halo_target: CanvasItem = null

const MOUSE_BUTTON: int = MOUSE_BUTTON_MIDDLE
const UP_KEY: int = KEY_SHIFT
const DOWN_KEY: int = KEY_CTRL

func _ready():
	set_process_input(true)
	self._target_finder = TargetFinder.new().init(self)
	
func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == self.MOUSE_BUTTON
		and event.pressed
	):
		self._handle_selection_input(event)
		
func _handle_selection_input(event: InputEventMouseButton) -> void:
	var scene_root: Node = self._get_scene_root()
	var target: CanvasItem
	
	if Input.is_key_pressed(self.UP_KEY):
		target = self._target_finder.find_target_above(scene_root, self.halo_target, event.position)
	elif Input.is_key_pressed(self.DOWN_KEY):
		target = self._target_finder.find_target_below(scene_root, self.halo_target, event.position)
	else:
		target = self._target_finder.find_target(scene_root, self.halo_target, event.position)
	
	self._set_target(target, scene_root)

func _set_target(target: CanvasItem, scene_root: Node) -> void:
	if self.halo_target != null:
		self.halo_target.disconnect("tree_exiting", self._on_target_tree_exiting)
	
	self.halo_target = target
	
	if target:
		self.halo_target.connect("tree_exiting", self._on_target_tree_exiting)
		HaloSingleton.set_target(self.halo_target, self.halo_target == scene_root)
	else:
		HaloSingleton.set_target(null)

func put_halo_on(target: CanvasItem) -> void:
	if self.halo_target != target:
		self._set_target(target, self._get_scene_root())
	
func _on_target_tree_exiting() -> void:
	self.halo_target.disconnect("tree_exiting", self._on_target_tree_exiting)
	self.put_halo_on(null)

func _get_scene_root() -> Node:
	return get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
