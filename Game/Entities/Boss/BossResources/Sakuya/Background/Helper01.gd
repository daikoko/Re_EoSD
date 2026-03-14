extends Sprite2D

@export var rotation_speed:float




func _process(delta: float) -> void:
	self.rotation += deg_to_rad(delta * rotation_speed)
