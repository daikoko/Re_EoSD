extends Node2D

const HELPER_14 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper14.tscn")

var RNG:RandomNumberGenerator
var disabled:bool = false

const DISTANCE := 180.0




func fire_loop(
		fire_time:float,
		color:Color,
		weight:int,
		weight_range:int,
		duration:float
	):
	
	%Timer.wait_time = fire_time
	%Timer.start()
	while disabled == false:
		var angle = RNG.randf_range(0, TAU)
		
		var laser_shooter = HELPER_14.instantiate()
		laser_shooter.position = Vector2.RIGHT.rotated(angle) * DISTANCE
		laser_shooter.rotation = angle
		laser_shooter.build(
			color,
			RNG.randi_range(
				weight - weight_range,
				weight + weight_range
			),
			duration
		)
		
		self.add_child(laser_shooter)
		
		await %Timer.timeout


func disable():
	disabled = true
	
	queue_free()
