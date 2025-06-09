class_name Halo extends Node2D

@onready var _delete_button: TextureButton = $DeleteButton
@onready var _move_button: TextureButton = $MoveButton
@onready var _move_v_button: TextureButton = $MoveVButton
@onready var _move_h_button: TextureButton = $MoveHButton
@onready var _rotate_button: TextureButton = $RotateButton
@onready var _reset_rotation_button: TextureButton = $ResetRotationButton
@onready var _duplicate_button: TextureButton = $DuplicateButton
@onready var _inspect_button: TextureButton = $InspectButton
@onready var _tree_visibility_button: TextureButton = $TreeVisibilityButton
@onready var _window: Window = $HaloInspectorWindow
@onready var _selection_rect: ColorRect = $SelectionRect

@onready var _name_tag: Label = $NameTag
@onready var _angle_tag: Label = $AngleTag
@onready var _position_tag: Label = $PositionTag

var _target: Node = null
var _target_is_root: bool = false	
var _target_has_scene_file: bool = false
var _target_scene_filename: String = ""
var _buttons: Array[TextureButton] = []
var _additional_buttons: Array[TextureButton] = []
var _tree_lines: Array[Line2D] = []
var _show_tree_lines: bool = false

const RADIUS_8: float = 16.0
const TREE_LINE_PARENT_COLOR: Color = Color.ORANGE
const TREE_LINE_CHILD_COLOR: Color = Color.DEEP_SKY_BLUE
const TREE_LINE_CENTER_COLOR: Color = Color.ANTIQUE_WHITE
const TREE_LINE_ALPHA: float = 0.8
const COPY_OFFSET: Vector2 = Vector2(10, 10)

var _radius: float = RADIUS_8

var _dragging: bool = false
var _dragging_v: bool = false
var _dragging_h: bool = false
var _rotating: bool = false

func set_target(target: CanvasItem, target_is_root: bool, additional_buttons: Array[TextureButton]) -> void:
	self._target = target
	self._target_is_root = target_is_root
	self._target_scene_filename = target.scene_file_path
	if target.scene_file_path != "" and not target_is_root:
		self._target_has_scene_file = true
	self._set_additional_buttons(additional_buttons)
	self._name_tag.text = self._target.name + " (" + str(self._get_depth()) + ")"
	self._angle_tag.text = self._rotation_string()
	self._position_tag.text = self._position_string()
	self._window.visible = false 
	self._window.title = self._target.get_class()
	self._target.item_rect_changed.connect(self._reposition)
	var inspector = self._window.get_node("Inspector")
	inspector.set_object(self._target)
	self._set_button_visibility()
	self._place_buttons()
	self._reposition()
	self._place_tree_lines()

func set_tree_line_visibility(visibility: bool) -> void:
	self._show_tree_lines = visibility
	for tree_line in self._tree_lines:
		tree_line.visible = visibility

func _fill_button_array() -> void:
	self._buttons = []
	if not self._target_is_root:
		self._buttons.append_array([
			self._move_button,
			self._move_v_button,
			self._move_h_button,
			self._rotate_button,
			self._reset_rotation_button
		])
	if self._target_has_scene_file and not self._target_is_root:
		self._buttons.append_array([
			self._duplicate_button
		])
	self._buttons.append_array([
		self._inspect_button,
		self._tree_visibility_button,
		self._delete_button
	])
	self._buttons.append_array(self._additional_buttons)

func _set_additional_buttons(additional_buttons: Array[TextureButton]) -> void:
	self._additional_buttons = additional_buttons
	for button in additional_buttons:
		if not self.is_ancestor_of(button):
			self.add_child(button)

func _set_button_visibility() -> void:
	self._move_button.visible = not self._target_is_root
	self._move_v_button.visible = not self._target_is_root
	self._move_h_button.visible = not self._target_is_root
	self._rotate_button.visible = not self._target_is_root
	self._reset_rotation_button.visible = not self._target_is_root
	self._duplicate_button.visible = self._target_has_scene_file and not self._target_is_root

func _rotation_string() -> String:
	return str(int(360 * self._target.rotation / (2 * PI)))

func _position_string() -> String:
	var position: Vector2 = self._target.global_position
	var result: String = "("
	result += str(position.x).pad_decimals(2)
	result += ", "
	result += str(position.y).pad_decimals(2)
	result += ")"
	return result

func _get_depth() -> int:
	var depth: int = 0
	var node: Node = self._target
	while node:
		node = node.get_parent()
		if node is CanvasItem:
			depth += 1
	return depth

func _place_buttons() -> void:
	self._fill_button_array()
	self._set_radius()
	self._position_buttons()
	self._position_tags()
	
func _set_radius() -> void:
	self._radius = self.RADIUS_8 * (sin(PI / 8) / sin(PI / self._buttons.size()))

func _position_buttons() -> void:
	for i in self._buttons.size():
		var angle: float = i * 2 * PI / self._buttons.size()
		self._buttons[i].position = Vector2(
			cos(angle) * self._radius,
			sin(angle) * self._radius
		) - (self._buttons[i].size * self._buttons[i].scale) / 2
	var string_size: Vector2 = self._name_tag.theme.default_font.get_string_size(
		self._name_tag.text, HORIZONTAL_ALIGNMENT_LEFT, -1, self._name_tag.theme.default_font_size
	)
	self._name_tag.position = Vector2(
		0, 
		-sin(1.5 * PI) * self._radius
	) + Vector2(-string_size.x / 2, string_size.y)

func _position_tags() -> void:
	self._angle_tag.position = Vector2(
		2 * cos(PI) * self._radius,
		0
	)
	self._position_tag.position = Vector2(
		1.5 * cos(0) * self._radius,
		0
	)

func _reposition() -> void:
	if not self._target_is_root:
		self.global_position = self._target.global_position
	else:
		self.global_position = Vector2.ZERO
	self._place_area_rect()

func _place_area_rect() -> void:
	if self._target is Control:
		self._selection_rect.size = self._target.get_global_rect().size
		self._selection_rect.global_position = self._target.global_position - self._selection_rect.size / 2
		self._selection_rect.visible = true
	elif self._target is Sprite2D:
		self._selection_rect.size = self._target.texture.get_size()
		self._selection_rect.global_position = self._target.global_position - self._selection_rect.size / 2
		self._selection_rect.visible = true
	elif self._target is CollisionShape2D:
		self._selection_rect.size = self._target.shape.get_rect().size
		self._selection_rect.global_position = self._target.global_position - self._selection_rect.size / 2
		self._selection_rect.visible = true
	else:
		self._selection_rect.visible = false

func _place_tree_lines() -> void:
	for tree_line in self._tree_lines:
		tree_line.queue_free()
	self._tree_lines.clear()
	self._place_children_tree_lines()
	self._place_parent_tree_line()

func _place_children_tree_lines() -> void:
	var queue: Array[Node] = self._target.get_children()
	while not queue.is_empty():
		var child: Node = queue.pop_front()
		if child is CanvasItem:
			self._place_tree_line(child)
		elif child is not Halo:
			queue.append_array(child.get_children())

func _place_parent_tree_line() -> void:
	var parent: Node = self._target.get_parent()
	if parent:
		while parent is not CanvasItem:
			parent = parent.get_parent()
			if not parent:
				break
	if parent:
		self._place_tree_line(parent, true)

func _place_tree_line(node: CanvasItem, is_parent: bool = false):
	var tree_line: Line2D = preload("res://addons/babylonian/halo/scenes/connection_line.tscn").instantiate()
	tree_line.points[0] = to_local(self._target.global_position)
	tree_line.points[1] = to_local(node.global_position)
	var line_color = self.TREE_LINE_CHILD_COLOR
	if is_parent:
		line_color = self.TREE_LINE_PARENT_COLOR
	line_color.a = TREE_LINE_ALPHA
	tree_line.gradient = Gradient.new()
	tree_line.gradient.set_colors(PackedColorArray([self.TREE_LINE_CENTER_COLOR, line_color]))
	tree_line.z_index = self._delete_button.z_index - 1
	tree_line.visible = self._show_tree_lines
	self.add_child(tree_line)
	self._tree_lines.append(tree_line)

func _perform_dragging() -> void:
	self._perform_dragging_translation()
	self._perform_dragging_rotation()

func _perform_dragging_translation() -> void:
	var button: TextureButton = null
	if self._dragging:
		button = self._move_button
	elif self._dragging_v:
		button = self._move_v_button
	elif self._dragging_h:
		button = self._move_h_button
	if self._dragging or self._dragging_h or self._dragging_v:
		var new_position: Vector2 = get_global_mouse_position() 
		if self._dragging:
			self._target.global_position = new_position
		elif self._dragging_v:
			self._target.global_position.y = new_position.y
		elif self._dragging_h:
			self._target.global_position.x = new_position.x
		self._reposition()

func _perform_dragging_rotation() -> void:
	if self._rotating:
		var angle: float = atan2(
			-self._target.global_position.y + get_global_mouse_position().y,
			-self._target.global_position.x + get_global_mouse_position().x,
		)
		var button_index: int = self._buttons.find(self._rotate_button)
		var angle_offset: float = button_index * 2 * PI / self._buttons.size()
		self._target.rotation = angle - angle_offset

func _set_state_strings() -> void:
	self._angle_tag.text = self._rotation_string()
	self._position_tag.text = self._position_string()

func _process(delta: float) -> void:
	self._perform_dragging()
	self._reposition()
	self._place_tree_lines()
	self._set_state_strings()
	
	B.game_probe(self._dragging_v)
	B.game_probe(self._dragging_h)
	B.game_probe(self._dragging)

func _on_delete_button_pressed() -> void:
	self._target.queue_free()
	HaloDispatcher.put_halo_on(null)

func _on_move_button_button_down() -> void:
	self._dragging = true

func _on_move_button_button_up() -> void:
	self._dragging = false

func _on_move_v_button_button_down() -> void:
	self._dragging_v = true

func _on_move_v_button_button_up() -> void:
	self._dragging_v = false

func _on_move_h_button_button_down() -> void:
	self._dragging_h = true

func _on_move_h_button_button_up() -> void:
	self._dragging_h = false

func _on_inspect_button_pressed() -> void:
	self._window.visible = not self._window.visible  

func _on_halo_inspector_window_close_requested() -> void:
	self._window.visible = false

func _on_rotate_button_button_down() -> void:
	self._rotating = true

func _on_rotate_button_button_up() -> void:
	self._rotating = false

func _on_reset_rotation_button_pressed() -> void:
	self._target.rotation = 0

func _on_duplicate_button_pressed() -> void:
	var target_parent: Node = self._target.get_parent()
	var copy: CanvasItem = load(self._target_scene_filename).instantiate()
	copy.global_position = self._target.global_position + self.COPY_OFFSET
	target_parent.add_child(copy)


func _on_move_v_button_pressed() -> void:
	print("PRESSED")
