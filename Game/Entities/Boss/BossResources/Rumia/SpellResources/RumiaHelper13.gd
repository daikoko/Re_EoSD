extends Node2D

const HELPER_14 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper14.tscn")

var RNG:RandomNumberGenerator
var direction:int = 1

signal freed




func fire() -> void:
	var line = HELPER_14.instantiate()
	if direction == 1:
		var random_position = Vector2(
			-200,
			RNG.randf_range(120, 280)
		)
		var center = Vector2(350, 240)
		var vector = center - random_position
		line.position = random_position
		line.rotation = vector.angle() + deg_to_rad(RNG.randf_range(-10, 10))
		line.right = true
		line.left = false
		self.connect("freed", line._on_Shooter_freed)
		GlobalStage.request_add_object.emit(line)
	else:
		var random_position = Vector2(
			900,
			RNG.randf_range(120, 280)
		)
		var center = Vector2(350, 240)
		var vector = center - random_position
		line.position = random_position
		line.rotation = vector.angle() + deg_to_rad(RNG.randf_range(-10, 10))
		line.right = false
		line.left = true
		self.connect("freed", line._on_Shooter_freed)
		GlobalStage.request_add_object.emit(line)
	
	direction *= -1


func disable() -> void:
	freed.emit()
	queue_free()
