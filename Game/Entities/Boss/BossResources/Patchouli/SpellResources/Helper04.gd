extends Node2D

const HELPER_05 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper05.tscn")

const RANGE_X := Vector2(20, 660)
const RANGE_Y := Vector2(-20, -20)

const RANGE_ROTATION_LEFT_MAX := 40
const RANGE_ROTATION_RIGHT_MAX := 40

var RNG:RandomNumberGenerator
var disabled:bool = false

signal shooter_disabled




func fire(spawn_amount:int):
	if disabled:
		return
	
	var path = HELPER_05.instantiate()
	path.RNG = RNG
	self.connect("shooter_disabled", path._on_Shooter_shooter_disabled)
	
	var random_position = Vector2(
		RNG.randf_range(RANGE_X.x, RANGE_X.y),
		RNG.randf_range(RANGE_Y.x, RANGE_Y.y)
	)
	var random_rotation
	
	var middle = RANGE_X.x + (0.5 * (RANGE_X.y - RANGE_X.x))
	if random_position.x < middle:
		var left_extent = (middle - random_position.x) / (middle - RANGE_X.x)
		random_rotation = RNG.randf_range(
			90 + (RANGE_ROTATION_LEFT_MAX * (1 - left_extent)),
			90 - (RANGE_ROTATION_RIGHT_MAX)
		)
	else:
		var right_extent = (random_position.x - middle) / (RANGE_X.y - middle)
		random_rotation = RNG.randf_range(
			90 + (RANGE_ROTATION_LEFT_MAX),
			90 - (RANGE_ROTATION_RIGHT_MAX * (1 - right_extent))
		)
	
	path.position = random_position
	path.rotation = deg_to_rad(random_rotation)
	GlobalStage.request_add_object.emit(path)
	
	path.spawn(spawn_amount)


func disable() -> void:
	disabled = true
	
	shooter_disabled.emit()
