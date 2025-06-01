extends Node2D

var target_finder: TargetFinder
var button_manager: HaloButtonManager
var undo_manager: UndoManager

var halo_target: CanvasItem = null
var halo: Node2D = null

var show_tree_lines: bool = false

const MOUSE_BUTTON: int = MOUSE_BUTTON_MIDDLE
const UP_KEY: int = KEY_SHIFT
const DOWN_KEY: int = KEY_CTRL
const MODIFIER_KEY: int = KEY_CTRL

func _ready():
	set_process_input(true)
	self.target_finder = TargetFinder.new().init(self)
	self.button_manager = HaloButtonManager.new()
	self.undo_manager = UndoManager.new().init(self.set_target)
	
func get_scene_root() -> Node:
	return get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)

func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == self.MOUSE_BUTTON
		and event.pressed
	):
		self._handle_selection_input(event)
	elif (
		event is InputEventKey
		and event.pressed 
		and Input.is_key_pressed(self.MODIFIER_KEY)
	):
		self._handle_undo_redo_input(event)
			
func _handle_selection_input(event: InputEventMouseButton) -> void:
	var scene_root: Node = self.get_scene_root()
	var target: CanvasItem
	if Input.is_key_pressed(self.UP_KEY):
		target = self.target_finder.find_target_above(scene_root, self.halo_target, event.position)
	elif Input.is_key_pressed(self.DOWN_KEY):
		target = self.target_finder.find_target_below(scene_root, self.halo_target, event.position)
	else:
		target = self.target_finder.find_target(scene_root, self.halo_target, event.position)
	self.set_target(target, scene_root)
	
func _handle_undo_redo_input(event: InputEventKey) -> void:
	var scene_root: Node = self.get_scene_root()
	if event.keycode == self.undo_manager.UNDO_KEY:
		self.undo_manager.undo(scene_root, self.halo_target)
	elif event.keycode == self.undo_manager.REDO_KEY:
		self.undo_manager.redo(scene_root, self.halo_target)		
			
func put_halo_on(target: CanvasItem) -> void:
	if self.halo_target != target:
		self.set_target(target, self.get_scene_root())

func set_target(target: CanvasItem, scene_root: Node, is_undo_redo: bool = false) -> void:
	if not self.halo:
		self.halo = preload("res://addons/babylonian/halo/scenes/halo.tscn").instantiate()
		scene_root.add_child(self.halo)
		self.halo.get_node("TreeVisibilityButton").button_down.connect(_on_tree_visibility_button_down)
		
	if self.halo_target and not is_undo_redo:
		self.undo_manager.push_to_undo_stack(self.halo_target)
		
	self.halo_target = target
	if target:
		var buttons: Array[TextureButton] = self.button_manager.get_buttons(target)
		self.halo.set_target(self.halo_target, self.halo_target == scene_root, buttons)
		self.halo.set_tree_line_visibility(self.show_tree_lines)
		self.halo.visible = true
	else:
		self.halo.visible = false
		
	if not is_undo_redo:
		self.undo_manager.clear_redo_stack()
		
func _on_tree_visibility_button_down() -> void:
	self.show_tree_lines = not self.show_tree_lines
	self.halo.set_tree_line_visibility(self.show_tree_lines)
	
