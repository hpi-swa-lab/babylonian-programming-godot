extends Window

@onready var _item_list: ItemList = $VBoxContainer/ItemList
@onready var _button: Button = $VBoxContainer/Button

var _children: Array[CanvasItem] = []
var _selected_child: CanvasItem = null


func set_children(children: Array[CanvasItem]) -> void:
	self._children = children
	self._item_list.clear()
	for child in children:
		self._item_list.add_item(child.name)


func _on_item_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	self._selected_child = null
	self._button.disabled = true


func _on_item_list_item_selected(index: int) -> void:
	self._selected_child = self._children[index]
	self._button.disabled = false


func _on_button_pressed() -> void:
	self._button.disabled = true
	HaloDispatcher.put_halo_on(self._selected_child)
