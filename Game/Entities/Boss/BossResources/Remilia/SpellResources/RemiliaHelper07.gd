extends Node2D

var RNG:RandomNumberGenerator
var disabled

const HELPER_08 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper08.tscn")




func fire(
		data:BulletData,
		spawner_count:int,
		distance:float,
		time:float,
		rotation_speed:float
	):
	
	var angle = RNG.randf_range(0, TAU)
	var angle_step = TAU / spawner_count
	for _i in spawner_count:
		var direction = Vector2.RIGHT.rotated(angle)
		
		fire_once(
			data,
			direction,
			distance,
			time,
			time,
			rotation_speed
		)
		
		angle += angle_step


func fire_once(
		data:BulletData,
		direction:Vector2,
		distance:float,
		time:float,
		delay:float,
		rotation_speed:float
	):
	
	await get_tree().process_frame
	if GlobalStage.is_current_stage_clear() or GlobalStage.is_current_player_bomb():
		while GlobalStage.is_current_stage_clear() or GlobalStage.is_current_player_bomb():
			await get_tree().process_frame
		
		await self.create_tween().tween_interval(0.6).finished
		await self.create_tween().tween_interval(delay).finished
	
	if disabled: return
	
	var bullet = HELPER_08.instantiate()
	bullet.position = self.global_position
	bullet.build(
		data,
		self.global_position,
		direction,
		distance,
		time,
		delay,
		deg_to_rad(rotation_speed)
	)
	
	bullet.bullet_deleted.connect(_on_Bullet_bullet_deleted)
	
	GlobalStage.request_add_object.emit(bullet)


func disable():
	disabled = true




func _on_Bullet_bullet_deleted(data, direction, distance, time, delay, rotation_speed):
	fire_once(
		data,
		direction,
		distance,
		time,
		delay,
		rotation_speed
	)
