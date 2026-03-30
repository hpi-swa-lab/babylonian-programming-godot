class_name InspectorTool
extends HaloTool

var _inspector_window: Window
var _target: Node2D
var _active = false
var _target_snapshot: Dictionary


func _init() -> void:
	self.name = "Inspector"
	self.description = "Open property inspector"
	self.color = Color.ORANGE
	self.icon = icon_from_atlas(1, 4)
	
	self._inspector_window = load("res://addons/babylonian/halo/scenes/inspector_window.tscn").instantiate()
	self._inspector_window.close_requested.connect(self._close_window)


func start_interaction() -> void:
	if self._active:
		self._close_window()
		return
	
	self._target = Halo.get_target()
	self._button.modulate = Color.DARK_RED
	self._inspector_window.title = self._target.get_class()
	Halo.add_child(self._inspector_window)
	var inspector = self._inspector_window.get_node("Inspector")
	inspector.set_object(self._target)
	self._active = true
	self._target_snapshot = self.take_snapshot()


func finish_interaction() -> void:
	if self._target == null:
		return
	
	var changed_properties = self.get_changed_properties()
	for property in changed_properties:
		Halo.persistence.set_property(self._target, property)
	self._target = null


func _close_window() -> void:
	self._button.modulate = Color.ORANGE
	Halo.remove_child(self._inspector_window)
	self._active = false


func take_snapshot() -> Dictionary:
	var snapshot = {}
	var property_list = self._target.get_property_list()
	
	for property in property_list:
		# Skip internal/editor properties
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or property.usage & PROPERTY_USAGE_DEFAULT:
			var prop_name = property.name
			snapshot[prop_name] = self._target.get(prop_name)
	return snapshot


func get_changed_properties() -> Array:
	var changed_properties = []
	
	var before = self._target_snapshot
	var after = self.take_snapshot()
	
	for key in after:
		if key not in before or before[key] != after[key]:
			changed_properties.append(key)
	
	return changed_properties
