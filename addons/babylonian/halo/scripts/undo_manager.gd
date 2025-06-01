class_name UndoManager extends RefCounted

const UNDO_KEY: int = KEY_Z
const REDO_KEY: int = KEY_Y

var undo_stack: Array[CanvasItem] = []
var redo_stack: Array[CanvasItem] = []
var set_target_callback: Callable

func init(set_target_callback: Callable) -> UndoManager:
	self.set_target_callback = set_target_callback
	return self

func _undo_redo(stack: Array[CanvasItem], scene_root: Node, halo_target: CanvasItem) -> void:
	var other_stack: Array[CanvasItem] = self.undo_stack if stack == self.redo_stack else self.redo_stack
	
	if stack.is_empty():
		if stack == self.undo_stack:
			self.set_target_callback.call(null, scene_root, true)
		return
		
	var new_target: CanvasItem = stack.pop_back()
	
	if scene_root.is_ancestor_of(new_target) and is_instance_valid(new_target):
		other_stack.push_back(halo_target)
		self.set_target_callback.call(new_target, scene_root, true)
	else:
		stack.clear()
			
func undo(scene_root: Node, halo_target: CanvasItem) -> void:
	self._undo_redo(self.undo_stack, scene_root, halo_target)
	
func redo(scene_root: Node, halo_target: CanvasItem) -> void:
	self._undo_redo(self.redo_stack, scene_root, halo_target)
	
func clear_redo_stack() -> void:
	self.redo_stack.clear()
	
func push_to_undo_stack(object: CanvasItem) -> void:
	self.undo_stack.push_back(object)
