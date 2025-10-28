class_name ProbeWindow extends Window

var _select_button: Button = null
var _display: Display = null
var _target: Node = null
var _property_name: String = ""

@onready var margin_container: MarginContainer = $MarginContainer
const MARGIN: int = 32

func _ready() -> void:
	self.close_requested.connect(self._on_close_requested)

func _process(delta: float) -> void:
	var value: Variant = self._target.get(self._property_name)
	self._display.update_value(value)

func set_target(target: Node, property_name: String) -> void:
	self._target = target
	self._property_name = property_name
	self.title = target.name + " - " + property_name
	
	self._set_display()
	self._add_display()
	self._add_select_button()

func _set_display() -> void:
	var value: Variant = self._target.get(self._property_name)
	
	if value is Color:
		self._display = ColorDisplay.new()
	elif value is float or value is int:
		self._display = FloatOverTimeDisplay.new()
	elif value is Vector2:
		self._display = VectorDisplay.new()
	else:
		self._display = TextDisplay.new()

func _add_display() -> void:
	self.margin_container.add_child(self._display)
	self.margin_container.add_theme_constant_override("margin_top", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_left", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_bottom", self.MARGIN)
	self.margin_container.add_theme_constant_override("margin_right", self.MARGIN)

func _add_select_button() -> void:
	self._select_button = Button.new()
	self._select_button.text = "S"
	self._select_button.pressed.connect(self._on_select_button_pressed)
	self.add_child(self._select_button)

func _on_select_button_pressed() -> void:
	HaloDispatcher.put_halo_on(self._target)

func _on_close_requested() -> void:
	queue_free()
