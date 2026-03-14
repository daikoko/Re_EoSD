extends Node2D

var RNG:RandomNumberGenerator
var direction:int = 1
var disabled:bool

const HELPER_13 := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper13.tscn")
const COLOR  := Color(1, 0, 0, 1)
const WEIGHT := 20

signal round_finished




func fire_round_01(
		fire_count:int, fire_duration:float
	):
	
	%Timer.wait_time = fire_duration / fire_count
	%Timer.start()
	for i in fire_count:
		if disabled:
			return
		
		var bullet = HELPER_13.instantiate()
		bullet.position = Vector2(
			RNG.randf_range( 80, 600),
			RNG.randf_range(240, 760),
		)
		bullet.rotation = bullet.position.angle_to_point(Vector2(340, 500)) + (
			RNG.randf_range(
				deg_to_rad(-60),
				deg_to_rad(60)
			)
		)
		bullet.color = COLOR
		bullet.weight = WEIGHT
		bullet.duration = 1.2
		bullet.delay = 0.2
		bullet.id = i
		GlobalStage.request_add_object.emit(bullet)
		
		await %Timer.timeout
	
	%Timer.stop()
	round_finished.emit()


func fire_round_02(
		fire_count:int, fire_duration:float
	):
	
	var angle = 0
	var angle_step = TAU / fire_count
	
	%Timer.wait_time = fire_duration / fire_count
	%Timer.start()
	for i in fire_count:
		if disabled:
			return
		
		var bullet = HELPER_13.instantiate()
		bullet.position = Vector2(340, 500) + Vector2.RIGHT.rotated(angle) * 240.0
		bullet.rotation = angle + PI
		bullet.color = COLOR
		bullet.weight = WEIGHT
		bullet.duration = 0.3
		bullet.delay = 0.1
		GlobalStage.request_add_object.emit(bullet)
		
		angle += angle_step
		await %Timer.timeout
	
	%Timer.stop()
	fire_round_02(
		fire_count, fire_duration
	)


func disable():
	disabled = true
