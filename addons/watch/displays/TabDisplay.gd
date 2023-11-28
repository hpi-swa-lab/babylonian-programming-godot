extends Display
class_name TabDisplay

var tab_container: TabContainer
var tabs: Array[Display] = []

func _init():
	tab_container = TabContainer.new()
	tab_container.set_anchors_preset(PRESET_FULL_RECT)
	add_child(tab_container)

func add_tab(name: String, display: Display):
	tab_container.add_child(display)
	tab_container.set_tab_title(len(tabs), name)
	tabs.append(display)
	display.annotation = annotation

func update_value(new_value: Variant):
	for tab in tabs:
		tab.update_value(new_value)
