class_name HaloManager
extends Node

var _halo_ui: Node2D = null
var _current_target: CanvasItem = null
var _halo_builder: HaloBuilder
var _external_buttons: Array[HaloTool] = []


func _ready() -> void:
	_halo_builder = HaloBuilder.new()
	add_child(_halo_builder)


func attach_to_target(target: CanvasItem) -> void:
	if _halo_ui != null:
		detach()
	
	_current_target = target
	_halo_ui = _halo_builder.build_halo(
		target
	)
	target.add_child(_halo_ui)


func detach() -> void:
	if _halo_ui != null and _halo_ui.get_parent() != null:
		_halo_ui.get_parent().remove_child(_halo_ui)
		_halo_ui.queue_free()
		_halo_ui = null
	_current_target = null


func update_tool_palette() -> void:
	if _current_target == null or _halo_ui == null:
		return
	
	_halo_builder.update_buttons(
		_halo_ui, 
	)


# Add a button from external scripts that persists across all palettes
func add_external_button(tool: HaloTool) -> void:
	_external_buttons.append(tool)
	if _halo_ui != null:
		update_tool_palette()
