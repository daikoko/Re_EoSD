extends Node2D

const HELPER_11 := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper11.tscn")
const HELPER_12 := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper12.tscn")

var RNG:RandomNumberGenerator




func fire_round(
		data:BulletData,
		start_angle:float,
		fire_count:int, fire_duration:float,
		distance_max_time:float,
		direction:int
	) -> void:
	
	var angle = start_angle
	for _i in 6:
		self.rotation = deg_to_rad(angle)
		
		var step = 1.0 / (fire_count - 1)
		for j in fire_count:
			%PathFollow.progress_ratio += step
			
			var distance_max   = (%PathFollow.global_position - self.global_position).length()
			var distance_time  = distance_max_time * (distance_max / 288)
			var distance_extra = RNG.randf_range(600, 800)
			
			var angle_start    = (%PathFollow.global_position - self.global_position).angle()
			var angle_max      = deg_to_rad(RNG.randf_range(60, 90)) * direction
			var angle_delay    = distance_time * RNG.randf_range(0.6, 0.9)
			var angle_time     = RNG.randf_range(4.0, 6.0)
			
			var origin        = self.global_position
			var wait_time     = fire_duration * (1 - (distance_max / 288))
			var max_speed    = RNG.randf_range(160, 240)
			
			fire_bullet(
				data,
				origin,
				wait_time,
				max_speed,
				distance_max, distance_time, distance_extra,
				angle_start, angle_max, angle_delay, angle_time,
			)
		
		angle += 60


func fire_bullet(
		data:BulletData,
		origin:Vector2,
		wait_time:float,
		max_speed:float,
		distance_max:float, distance_time:float, distance_extra:float,
		angle_start:float, angle_max:float, angle_delay:float, angle_time:float,
	) -> void:
	
	if GlobalStage.is_current_stage_clear():
		return
	
	await create_tween().tween_interval(wait_time).finished
	
	var bullet = HELPER_11.instantiate()
	bullet.position = self.global_position
	bullet.rotation = angle_start
	bullet.set_data(data)
	GlobalStage.request_add_object.emit(bullet)
	
	bullet.activate(
		origin,
		max_speed,
		distance_max, distance_time, distance_extra,
		angle_start, angle_max, angle_delay, angle_time,
	)
	
	%Sound.play()


func fire_snow(
		direction:int
	) -> void:
	
	if GlobalStage.is_current_stage_clear():
		return
	
	var down_speed        = RNG.randf_range(80, 120)
	var acceleration_time = RNG.randf_range(2.0, 2.4)
	var rotatation_speed  = RNG.randf_range(30, 60)   * direction
	
	var bullet = HELPER_12.instantiate()
	bullet.position.x = RNG.randf_range(20, 660)
	bullet.position.y = -60
	bullet.RNG = RNG
	
	GlobalStage.request_add_object.emit(bullet)
	
	bullet.activate(
		down_speed,
		acceleration_time,
		rotatation_speed
	)


func disable() -> void:
	queue_free()
