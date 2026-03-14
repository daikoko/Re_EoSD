extends Node2D

var RNG:RandomNumberGenerator
var direction:int = 1
var disabled:bool

const HELPER_11 := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper11.tscn")

signal round_finished




func fire_round_01(
		fire_count:int, fire_duration:float
	):
	
	%Timer.wait_time = fire_duration / fire_count
	%Timer.start()
	for _i in fire_count:
		if disabled:
			return
		
		var bullet = HELPER_11.instantiate()
		bullet.position = Vector2(
			RNG.randf_range(100, 580),
			RNG.randf_range(120, 200),
		)
		bullet.speed          = RNG.randf_range(160, 200)
		bullet.direction      = Vector2.DOWN
		bullet.rotation_speed = RNG.randf_range(45, 60) * direction
		GlobalStage.request_add_object.emit(bullet)
		
		direction *= -1
		await %Timer.timeout
	
	%Timer.stop()
	round_finished.emit()


func fire_round_02(
		fire_count:int, fire_duration:float
	):
	
	%Timer.wait_time = fire_duration / fire_count
	%Timer.start()
	for _i in fire_count:
		if disabled:
			return
		
		if direction == 1:
			var bullet = HELPER_11.instantiate()
			bullet.position = Vector2(
				RNG.randf_range(60,  120),
				RNG.randf_range(520, 740),
			)
			bullet.speed          = RNG.randf_range(160, 200)
			bullet.direction      = Vector2.RIGHT
			bullet.rotation_speed = RNG.randf_range(45, 60) * direction
			GlobalStage.request_add_object.emit(bullet)
		else:
			var bullet = HELPER_11.instantiate()
			bullet.position = Vector2(
				RNG.randf_range(560, 620),
				RNG.randf_range(260, 480),
			)
			bullet.speed          = RNG.randf_range(160, 200)
			bullet.direction      = Vector2.LEFT
			bullet.rotation_speed = RNG.randf_range(45, 60) * direction
			GlobalStage.request_add_object.emit(bullet)
		
		direction *= -1
		await %Timer.timeout
	
	%Timer.stop()
	round_finished.emit()


func disable():
	disabled = true
