extends Node2D

var _halo_controller: HaloController
var _halo_ui_builder: HaloUIBuilder
var config: HaloConfig
var persistence: HaloPersistenceManager

var _target: Node2D = null
var _active_tool: HaloTool = null

var _ui: Node2D
var _remote_transform: RemoteTransform2D = null

var _tools: Array[HaloTool] = [
	AxisMoveTool.new(),
	RotateTool.new(),
	InspectorTool.new(),
	CopyTool.new(),
	DisableTool.new(),
	DeleteTool.new(),
	SaveTool.new()
]


func _ready() -> void:
	set_process_input(true)

	self.config = HaloConfig.new()
	self._halo_controller = HaloController.new()
	self._halo_ui_builder = HaloUIBuilder.new()
	self.persistence = HaloPersistenceManager.new()
	self.persistence.init(self.config)
	add_child(self._halo_controller)
	add_child(self.persistence)


func get_target() -> Node2D:
	return _target


func set_target(target: Node2D) -> void:
	print("[HALO] set target: ", target)
	self.clear_target()
	if target == null:
		return

	self._target = target
	self._target.tree_exiting.connect(self.clear_target)
	self._attach_ui()


func clear_target() -> void:
	if _target == null:
		return
	if self._target.tree_exiting.is_connected(self.clear_target):
		self._target.tree_exiting.disconnect(self.clear_target)
	self.finish_previous_tool_interaction()
	self._detach_ui()
	_target = null


func add_tool(tool: HaloTool, allow_duplicate_name: bool = false) -> void:
	if allow_duplicate_name or not self._tools.any(func(t): return tool.name == t.name):
		self._tools.append(tool)
	else:
		push_warning("Tool '" + tool.name + "' already exists and was not added.")


func set_active_tool(tool: HaloTool) -> void:
	self._active_tool = tool
	

func _process(delta: float) -> void:
	if self._active_tool != null:
		self._active_tool.interact(delta)


func finish_previous_tool_interaction() -> void:
	if self._active_tool != null:
		self._active_tool.finish_interaction()
		self._active_tool = null


func _attach_ui() -> void:
	self._ui = self._halo_ui_builder.get_halo_ui(self._target, self._tools)
	self._ui.global_position = _target.global_position
	self.add_child(_ui)

	self._remote_transform = RemoteTransform2D.new()
	self._remote_transform.remote_path = _ui.get_path()
	self._remote_transform.update_position = true
	self._remote_transform.update_rotation = false
	self._remote_transform.update_scale = false
	self._target.add_child(self._remote_transform)


func _detach_ui() -> void:
	# free RemoteTransform
	if self._remote_transform != null:
		if self._remote_transform.get_parent():
			self._remote_transform.get_parent().remove_child(self._remote_transform)
		self._remote_transform.queue_free()
		self._remote_transform = null
	# remove ui from canvas, but don't free
	if self._ui != null:
		if self._ui.get_parent() == self:
			self.remove_child(_ui)
