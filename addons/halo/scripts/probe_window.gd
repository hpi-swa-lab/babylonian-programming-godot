class_name ProbeWindow extends Window

var button: Button = null
var display: Display = null
var target: Node = null
var property_name: String = ""

@onready var margin_container: MarginContainer = $MarginContainer
const MARGIN: int = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.close_requested.connect(self._on_close_requested)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var value: Variant = self.target.get(self.property_name)
	self.display.update_value(value)
	
func set_target(target: Node, property_name: String) -> void:
	self.target = target
	self.property_name = property_name
	var value: Variant = target.get(property_name)
	
	if value is Color:
		self.display = ColorDisplay.new()
	elif value is float or value is int:
		self.display = FloatOverTimeDisplay.new()
	elif value is Vector2:
		self.display = VectorDisplay.new()
	else:
		self.display = TextDisplay.new()
		
	self.title = target.name + " - " + property_name
	self.margin_container.add_child(self.display)
	self.margin_container.add_theme_constant_override("margin_top", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_left", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_bottom", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_right", self.MARGIN)
	
	self.button = Button.new()
	self.button.text = "S"
	self.button.pressed.connect(self._on_select_button_pressed)
	self.add_child(self.button)
	
func _on_select_button_pressed() -> void:
	HaloDispatcher.put_halo_on(self.target)
		
func _on_close_requested() -> void:
	queue_free()
