extends Node2D

const DISTANCE := 40
const HELPER_18 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper18.tscn")
const STAR_LARGE := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Bullet_PatchouliStarLarge.tres")
const STAR_SMALL := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Bullet_PatchouliStarSmall.tres")

const BULLET_ROTATION_SPEED := - TAU / 6

var spawners:Array = []
var disabled:bool

var RNG:RandomNumberGenerator

signal finished_round




func build(layout_spawner_count) -> void:
	var angle = 0
	var angle_step = TAU / layout_spawner_count
	
	for _i in layout_spawner_count:
		var spawner = Marker2D.new()
		spawner.position = Vector2.RIGHT.rotated(angle) * DISTANCE
		spawner.rotation = angle
		
		spawners.append(spawner)
		self.add_child(spawner)
		
		angle += angle_step


func fire(
		round_count:int, round_delay:float,
		fire_count:int, fire_duration:float,
		bullet_speed:float, bullet_turning:float
	) -> void:
	
	if disabled: return
	
	var direction = 1
	
	for _i in round_count:
		for _j in 1:
			if disabled: return
			
			for spawner in spawners:
				var bullet = HELPER_18.instantiate()
				bullet.build(
					STAR_LARGE,
					bullet_speed,
					bullet_turning * direction,
					BULLET_ROTATION_SPEED * direction,
				)
				bullet.transform = spawner.global_transform
				GlobalStage.request_add_object.emit(bullet)
				%Sound.play()
			
			await self.create_tween().tween_interval(fire_duration / (fire_count + 1)).finished
		
		for _j in fire_count:
			if disabled: return
			
			for spawner in spawners:
				var bullet = HELPER_18.instantiate()
				bullet.build(
					STAR_SMALL,
					bullet_speed,
					bullet_turning * direction,
					BULLET_ROTATION_SPEED * direction,
				)
				bullet.transform = spawner.global_transform
				GlobalStage.request_add_object.emit(bullet)
				%Sound.play()
			
			await self.create_tween().tween_interval(fire_duration / (fire_count + 1)).finished
		
		direction *= -1
		await self.create_tween().tween_interval(round_delay).finished
	
	finished_round.emit()


func disable() -> void:
	disabled = true
