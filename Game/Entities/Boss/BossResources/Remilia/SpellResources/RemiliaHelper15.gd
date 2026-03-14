extends Node2D

const HELPER_16 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper16.tscn")
const HELPER_17 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper17.tscn")

var RNG:RandomNumberGenerator

signal freed




func start_line(
		position:Vector2,
		rotation:float,
		mute:bool = false
	) -> void:
	
	var line = HELPER_16.instantiate()
	line.position = position
	line.rotation = deg_to_rad(rotation)
	line.mute = mute
	line.RNG = RNG
	self.freed.connect(line._on_Shooter_freed)
	
	GlobalStage.request_add_object.emit(line)


func start_cross(
		position:Vector2,
	) -> void:
	
	var cross = HELPER_17.instantiate()
	cross.position = position
	cross.RNG = RNG
	self.freed.connect(cross._on_Shooter_freed)
	
	GlobalStage.request_add_object.emit(cross)


func fire_line() -> void:
	var random_position = Vector2(
		RNG.randf_range(40, 640),
		-20
	)
	var random_rotation = 0
	if (random_position.x < 340): random_rotation = RNG.randf_range(60,  90)
	else:                         random_rotation = RNG.randf_range(90, 120)
	
	start_line(
		random_position,
		random_rotation
	)


func fire_circle(lines:int) -> void:
	var angle = RNG.randf_range(0, 360.0)
	var step = 360.0 / lines
	
	for i in lines:
		start_line(
			self.global_position,
			angle,
			not ((i == 0) or (i == 3) or (i == 6))
		)
		
		angle += step


func fire_cross() -> void:
	var random_position = Vector2(
		RNG.randf_range(80, 600),
		RNG.randf_range(80, 400)
	)
	
	start_cross(
		random_position
	)


func disable():
	freed.emit()
	queue_free()
