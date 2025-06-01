class_name ProbeWindow extends Window

var select_button: Button = null
var display: Display = null
var target: Node = null
var property_name: String = ""

@onready var margin_container: MarginContainer = $MarginContainer
const MARGIN: int = 32

func _ready() -> void:
	self.close_requested.connect(self._on_close_requested)
	
func _process(delta: float) -> void:
	var value: Variant = self.target.get(self.property_name)
	self.display.update_value(value)
	
func _set_display() -> void:
	var value: Variant = self.target.get(self.property_name)
	
	if value is Color:
		self.display = ColorDisplay.new()
	elif value is float or value is int:
		self.display = FloatOverTimeDisplay.new()
	elif value is Vector2:
		self.display = VectorDisplay.new()
	else:
		self.display = TextDisplay.new()
		
func _add_margin_container() -> void:
	self.margin_container.add_child(self.display)
	self.margin_container.add_theme_constant_override("margin_top", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_left", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_bottom", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_right", self.MARGIN)
	
func _add_select_button() -> void:
	self.select_button = Button.new()
	self.select_button.text = "S"
	self.select_button.pressed.connect(self._on_select_button_pressed)
	self.add_child(self.select_button)
	
func set_target(target: Node, property_name: String) -> void:
	self.target = target
	self.property_name = property_name
	self.title = target.name + " - " + property_name
	
	self._set_display()
	self._add_margin_container()
	self._add_select_button()
	
func _on_select_button_pressed() -> void:
	HaloDispatcher.put_halo_on(self.target)
		
func _on_close_requested() -> void:
	queue_free()
