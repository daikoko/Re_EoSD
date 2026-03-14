extends Node2D

var rotation_speed:float




func _process(delta: float) -> void:
	%Sprite.rotation += delta * rotation_speed
