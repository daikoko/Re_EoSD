extends Node2D

var spawners:Array = []

var RNG:RandomNumberGenerator
var disabled:bool

const LAYOUT_DISTANCE := 680.0
const DISTANCE_MAX :=    520.0

const HELPER_12 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper12.tscn")

signal finished_round




func build(
		layout_spawner_count:int
	):
	
	var angle = 0
	var angle_step = TAU / layout_spawner_count
	for _in in layout_spawner_count:
		var spawner = Marker2D.new()
		spawner.position = Vector2.RIGHT.rotated(angle) * LAYOUT_DISTANCE
		spawner.rotation = angle - PI
		spawners.append(spawner)
		
		self.add_child(spawner)
		
		angle += angle_step


func fire(
		data:BulletData,
		fire_count:int, fire_duration:float,
		bullet_speed:float, bullet_speed_range:float,
		linear_delay:float, linear_delay_range:float,
		linear_time:float, linear_time_range:float,
		linear_speed:float, linear_speed_range:float,
	):
	
	%Timer.wait_time = fire_duration / fire_count
	%Timer.start()
	for _i in fire_count:
		for spawner in spawners:
			%Sound.play()
			
			self.rotation = RNG.randf_range(0, TAU)
			
			var bullet = HELPER_12.instantiate()
			bullet.transform = spawner.global_transform
			bullet.build(
				data,
				bullet_speed + RNG.randf_range(-bullet_speed_range, bullet_speed_range),
				linear_delay + RNG.randf_range(-linear_delay_range, linear_delay_range),
				linear_time +  RNG.randf_range(-linear_time_range,  linear_time_range),
				linear_speed + RNG.randf_range(-linear_speed_range, linear_speed_range),
				DISTANCE_MAX
			)
			
			GlobalStage.request_add_object.emit(bullet)
		
		await %Timer.timeout
	
	finished_round.emit()


func disable():
	disabled = true
