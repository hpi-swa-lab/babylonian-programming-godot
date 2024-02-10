class_name TabDisplay extends Display

var tab_container: TabContainer
var tabs: Array[Display] = []

func _init():
	tab_container = TabContainer.new()
	tab_container.set_anchors_preset(PRESET_FULL_RECT)
	tab_container.clip_contents = true
	tab_container.tab_focus_mode = Control.FOCUS_NONE
	add_child(tab_container)

func add_tab(name: String, display: Display):
	tab_container.add_child(display)
	tab_container.set_tab_title(len(tabs), name)
	tabs.append(display)
	display.annotation = annotation
	return display

func update_value(new_value: Variant):
	for tab in tabs:
		tab.update_value(new_value)
