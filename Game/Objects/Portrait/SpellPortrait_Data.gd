extends Resource
class_name SpellPortrait_Data

enum CONFIGURATION {
	LEFT,
	RIGHT,
	MIDDLE
}


@export var texture:Texture2D

@export_group("Configuration")
@export var offset:Vector2 = Vector2.ZERO
@export var scale:Vector2 = Vector2.ONE
@export var mode:CONFIGURATION
