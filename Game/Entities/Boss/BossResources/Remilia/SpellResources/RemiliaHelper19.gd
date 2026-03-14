extends Node2D

const HELPER_20 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper20.tscn")

var RNG:RandomNumberGenerator



func fire(
		primary_spawners:int,
		secondary_spawners:int,
		fire_time:float,
		direction:int
	) -> void:
	
	if GlobalStage.is_current_stage_clear():
		return
	
	for i in primary_spawners:
		var bullet = HELPER_20.instantiate()
		bullet.build(
			secondary_spawners,
			RNG.randf_range(0, TAU)
		)
		bullet.mute = not ((i == 0) or (i == 4))
		
		var origin = self.global_position
		var distance = 20
		var velocity = 560
		var acceleration = -360
		var angle = self.rotation + ((float(i) / primary_spawners) * TAU)
		var angle_speed = deg_to_rad(30)
		
		GlobalStage.request_add_object.emit(bullet)
		bullet.activate(
			origin,
			distance,
			velocity,
			acceleration,
			angle,
			angle_speed,
			direction,
			fire_time
		)


func disable() -> void:
	queue_free()
