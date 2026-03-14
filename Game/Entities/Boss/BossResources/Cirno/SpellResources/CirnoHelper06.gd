extends Node2D

const ROUNDS := 10
const START_DISTANCE := 40.0
const DISTANCE := 200.0
const EDGE_DISTANCE := 260.0
const DISTANCE_WIDTH := 60.0
const WIDTH := 20.0
const START_ANGLE := 60.0
const MAX_ANGLE := 120.0

const BULLET_A := GlobalShooter.STONE_BLUE
const BULLET_B := GlobalShooter.BRIGHT_CYAN
const BULLET_C := GlobalShooter.STONE_CYAN

const DELAY := 0.8
const TIME := 1.0

var rng:RandomNumberGenerator
var mute:bool




func spawn_bullets(
		body_count:int, body_speed:float,
		edge_count:int, edge_speed:float
	) -> void:
	
	var distance_step = DISTANCE / ROUNDS
	var count:int = body_count / ROUNDS
	
	%FireTimer.start()
	for i in ROUNDS:
		var base_x = i * distance_step
		
		if !mute:
			%Sound.play()
		for j in count:
			var x = rng.randf_range(base_x, base_x + distance_step)
			var y = 0
			if x < DISTANCE_WIDTH:
				var width = WIDTH * (x / DISTANCE_WIDTH)
				y = rng.randf_range(-width/2, width/2)
			else:
				y = rng.randf_range(-WIDTH/2, WIDTH/2)
			
			var trans = global_transform.translated(
				Vector2(x + START_DISTANCE, y).rotated(global_rotation)
			)
			
			var angle_range = START_ANGLE + (MAX_ANGLE * (x / DISTANCE))
			
			var delay = DELAY + rng.randf_range(0, 0.2)
			var time = TIME + rng.randf_range(0, 1.0)
			var speed = body_speed + rng.randf_range(-70, 10)
			var angle = rng.randf_range(-angle_range/2, angle_range/2)
			
			
			GlobalPool.bullet_linear_spawned.emit(
				BULLET_A, trans,
				0, 0, 0, 0,
				delay, time, speed, deg_to_rad(angle)
			)
		
		await %FireTimer.timeout
	
	var center_pos = Vector2(START_DISTANCE + EDGE_DISTANCE, 0)
	var center_trans = global_transform * Transform2D(
		0, center_pos
	)
	
	GlobalPool.bullet_linear_spawned.emit(
		BULLET_B, center_trans,
		0, 0, 0, 0,
		DELAY, TIME, edge_speed
	)
	
	for i in edge_count:
		var angle = i * (TAU / edge_count)
		var pos = 30 * Vector2.RIGHT.rotated(angle)
		var trans = center_trans * Transform2D(
			0, pos
		)
		
		GlobalPool.bullet_linear_spawned.emit(
			BULLET_C, trans,
			0, 0, angle, 0,
			DELAY, TIME, edge_speed
		)
