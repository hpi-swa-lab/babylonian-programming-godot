extends Node

@export var texture: Texture2D = null
@export var active: bool = true

func _ready() -> void:
	var button_handler = func(target: CanvasItem) -> void:
		print(target.name)
		
	if self.active:
		HaloDispatcher.button_manager.add_button(
			self.texture, 
			button_handler,
			[],
			Color.GREEN
		)
