class_name Halo extends Node2D

@onready var delete_button: TextureButton = $DeleteButton
@onready var move_button: TextureButton = $MoveButton
@onready var move_v_button: TextureButton = $MoveVButton
@onready var move_h_button: TextureButton = $MoveHButton
@onready var rotate_button: TextureButton = $RotateButton
@onready var reset_rotation_button: TextureButton = $ResetRotationButton
@onready var inspect_button: TextureButton = $InspectButton
@onready var tree_visibility_button: TextureButton = $TreeVisibilityButton
@onready var window: Window = $HaloInspectorWindow
@onready var selection_rect: ColorRect = $SelectionRect

@onready var name_tag: Label = $NameTag
@onready var angle_tag: Label = $AngleTag
@onready var position_tag: Label = $PositionTag

@export var target: Node = null

var buttons: Array = []
var additional_buttons: Array = []

var tree_lines: Array = []
var show_tree_lines: bool = false

const RADIUS: float = 16.0
const TREE_LINE_PARENT_COLOR: Color = Color.ORANGE
const TREE_LINE_CHILD_COLOR: Color = Color.BLUE
const TREE_LINE_CENTER_COLOR: Color = Color.ANTIQUE_WHITE
const TREE_LINE_ALPHA: float = 0.8

var dragging: bool = false
var dragging_v: bool = false
var dragging_h: bool = false
var rotating: bool = false

var target_is_root: bool = false	

func set_target(target: CanvasItem, target_is_root: bool, additional_buttons: Array) -> void:
	self.target = target
	self.target_is_root = target_is_root
	self.additional_buttons = additional_buttons
	for button in additional_buttons:
		if not self.is_ancestor_of(button):
			self.add_child(button)
	
	self.name_tag.text = self.target.name + " (" + str(self.get_depth()) + ")"
	self.angle_tag.text = self.rotation_string()
	self.position_tag.text = self.position_string()
	self.window.visible = false 
	self.window.title = self.target.get_class()
	self.target.item_rect_changed.connect(reposition)
	var inspector = self.window.get_node("Inspector")
	inspector.set_object(self.target)
	
	self.move_button.visible = not self.target_is_root
	self.move_v_button.visible = not self.target_is_root
	self.move_h_button.visible = not self.target_is_root
	self.rotate_button.visible = not self.target_is_root
	self.reset_rotation_button.visible = not self.target_is_root
	
	self.place_buttons()
	self.reposition()
	self.place_tree_lines()
	
func rotation_string() -> String:
	return str(int(360 * self.target.rotation / (2 * PI)))
	
func position_string() -> String:
	var position: Vector2 = self.target.global_position
	var result: String = "("
	result += str(position.x).pad_decimals(2)
	result += ", "
	result += str(position.y).pad_decimals(2)
	result += ")"
	return result
	
func get_depth() -> int:
	var depth: int = 0
	var node: Node = self.target
	while node:
		node = node.get_parent()
		if node is CanvasItem:
			depth += 1
	return depth
	
func set_tree_line_visibility(visibility: bool) -> void:
	self.show_tree_lines = visibility
	for tree_line in self.tree_lines:
		tree_line.visible = visibility
	
func place_buttons() -> void:
	self.buttons = []
	if not self.target_is_root:
		self.buttons.append_array([
			self.move_button,
			self.move_v_button,
			self.move_h_button,
			self.rotate_button,
			self.reset_rotation_button
		])
	self.buttons.append_array([
		self.inspect_button,
		self.tree_visibility_button,
		self.delete_button
	])
	self.buttons.append_array(self.additional_buttons)
	
	for i in buttons.size():
		var angle: float = i * 2 * PI / buttons.size()
		buttons[i].position = Vector2(
			cos(angle) * self.RADIUS,
			sin(angle) * self.RADIUS
		) - (buttons[i].size * buttons[i].scale) / 2
		
	var string_size: Vector2 = self.name_tag.theme.default_font.get_string_size(
		self.name_tag.text, HORIZONTAL_ALIGNMENT_LEFT, -1, self.name_tag.theme.default_font_size
	)
	self.name_tag.position = Vector2(
		0, 
		-sin(1.5 * PI) * RADIUS
	) + Vector2(-string_size.x / 2, string_size.y)
	
	self.angle_tag.position = Vector2(
		2 * cos(PI) * RADIUS,
		0
	)
	self.position_tag.position = Vector2(
		1.5 * cos(0) * RADIUS,
		0
	)
		
func reposition() -> void:
	if not self.target_is_root:
		self.global_position = self.target.global_position
	else:
		self.global_position = Vector2.ZERO
		
	if self.target is Control:
		self.selection_rect.size = self.target.get_global_rect().size
		self.selection_rect.global_position = self.target.global_position - self.selection_rect.size / 2
		self.selection_rect.visible = true
	elif self.target is Sprite2D:
		self.selection_rect.size = self.target.texture.get_size()
		self.selection_rect.global_position = self.target.global_position - self.selection_rect.size / 2
		self.selection_rect.visible = true
	elif self.target is CollisionShape2D:
		self.selection_rect.size = self.target.shape.get_rect().size
		self.selection_rect.global_position = self.target.global_position - self.selection_rect.size / 2
		self.selection_rect.visible = true
	else:
		self.selection_rect.visible = false
	
func place_tree_line(node: CanvasItem, is_parent: bool = false):
	var tree_line: Line2D = preload("res://addons/babylonian/halo/scenes/connection_line.tscn").instantiate()
	tree_line.points[0] = to_local(self.target.global_position)
	tree_line.points[1] = to_local(node.global_position)
	var line_color = self.TREE_LINE_CHILD_COLOR
	if is_parent:
		line_color = self.TREE_LINE_PARENT_COLOR
	line_color.a = TREE_LINE_ALPHA
	tree_line.gradient = Gradient.new()
	tree_line.gradient.set_colors(PackedColorArray([self.TREE_LINE_CENTER_COLOR, line_color]))
	tree_line.z_index = self.delete_button.z_index - 1
	tree_line.visible = self.show_tree_lines
	self.add_child(tree_line)
	self.tree_lines.append(tree_line)
	
func place_tree_lines() -> void:
	for tree_line in self.tree_lines:
		tree_line.queue_free()
	self.tree_lines.clear()
	
	var queue: Array = self.target.get_children()
	while not queue.is_empty():
		var child: Node = queue.pop_front()
		if child is CanvasItem:
			self.place_tree_line(child)
		elif child is not Halo:
			queue.append_array(child.get_children())
	
	var parent: Node = self.target.get_parent()
	if parent:
		while parent is not CanvasItem:
			parent = parent.get_parent()
			if not parent:
				break
	if parent:
		self.place_tree_line(parent, true)
		

func perform_dragging() -> void:
	var button: TextureButton = null
	if self.dragging:
		button = self.move_button
	elif self.dragging_v:
		button = self.move_v_button
	elif self.dragging_h:
		button = self.move_h_button
	if self.dragging or self.dragging_h or self.dragging_v:
		var new_position: Vector2 = (
			get_global_mouse_position() 
			#- button.position - (
				#button.size * button.scale
			#) / 2
		)
		if self.dragging:
			self.target.global_position = new_position
		elif self.dragging_v:
			self.target.global_position.y = new_position.y
		elif self.dragging_h:
			self.target.global_position.x = new_position.x
			
		self.reposition()
			
	if self.rotating:
		var angle: float = atan2(
			-self.target.global_position.y + get_global_mouse_position().y,
			-self.target.global_position.x + get_global_mouse_position().x,
		)
		var button_index: int = self.buttons.find(self.rotate_button)
		var angle_offset: float = button_index * 2 * PI / buttons.size()
		self.target.rotation = angle - angle_offset
		
func _process(delta: float) -> void:
	self.perform_dragging()
	self.reposition()
	self.place_tree_lines()
	
	self.angle_tag.text = self.rotation_string()
	self.position_tag.text = self.position_string()

func _on_delete_button_pressed() -> void:
	target.queue_free()
	self.queue_free()

func _on_move_button_button_down() -> void:
	self.dragging = true

func _on_move_button_button_up() -> void:
	self.dragging = false

func _on_move_v_button_button_down() -> void:
	self.dragging_v = true

func _on_move_v_button_button_up() -> void:
	self.dragging_v = false

func _on_move_h_button_button_down() -> void:
	self.dragging_h = true

func _on_move_h_button_button_up() -> void:
	self.dragging_h = false

func _on_inspect_button_pressed() -> void:
	self.window.visible = not self.window.visible  

func _on_halo_inspector_window_close_requested() -> void:
	self.window.visible = false

func _on_rotate_button_button_down() -> void:
	self.rotating = true

func _on_rotate_button_button_up() -> void:
	self.rotating = false

func _on_reset_rotation_button_pressed() -> void:
	self.target.rotation = 0
