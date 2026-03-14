extends Node2D




func _process(_delta: float) -> void:
	%Sprite.global_rotation = 0
	%Shooters.global_rotation = 0




func get_shots():
	return [%Marker]
