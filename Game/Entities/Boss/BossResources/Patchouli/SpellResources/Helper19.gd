extends Node2D

const START_TIME := 0.8
const DISTANCE := 240

var time:float
var spawners:Array = []
var firing:bool
var disabled:bool

var RNG:RandomNumberGenerator

const HELPER_20 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper20.tscn")

signal finished_start




func _ready() -> void:
	%Sprite.scale = Vector2.ONE
	%Sprite.modulate.a = 0
	%Collider.disable()
	
	%Particles.emitting = false


func _process(delta:float) -> void:
	%ShadowHandler.modulate = %Sprite.modulate
	
	if not firing: return
	
	time += delta
	%Shooter.rotation = deg_to_rad(90 + (16 * sin(1.0 * time)))




func build(
		layout_spawner_count:int,
		layout_column_count:int,
		layout_column_range:float,
		layout_shot_range:float
	):
	
	layout_column_range = deg_to_rad(layout_column_range)
	layout_shot_range = deg_to_rad(layout_shot_range)
	
	var angle = - layout_shot_range / 2
	var angle_step_spawner = layout_column_range / (layout_spawner_count - 1)
	var angle_step_column = (layout_shot_range - (layout_column_count * layout_column_range)) / (layout_column_count - 1)
	
	for _i in layout_column_count:
		for _j in layout_spawner_count:
			var spawner = Marker2D.new()
			spawner.position = Vector2.RIGHT.rotated(angle) * DISTANCE
			spawner.rotation = angle
			spawners.append(spawner)
			%Shooter.add_child(spawner)
			
			angle += angle_step_spawner
		
		angle -= angle_step_spawner
		angle += angle_step_column


func start(
		fire_time:float,
		bullet_speed:float, bullet_speed_range:float,
		turn_delay:float,   turn_delay_range:float,
		turn_time:float,    turn_time_range:float,
		turn_max:float,     turn_max_range:float,
	):
	
	%Particles.emitting = true
	
	%ShadowHandler.effect_start()
	var SunTween = self.create_tween().set_parallel(true)
	SunTween.tween_property(%Sprite, "scale",      Vector2.ONE * 0.2, START_TIME)
	SunTween.tween_property(%Sprite, "modulate:a", 1.0,               START_TIME)
	await SunTween.finished
	
	%ShadowHandler.effect_stop()
	%Collider.enable()
	
	firing = true
	finished_start.emit()
	
	%Timer.wait_time = fire_time
	%Timer.start()
	while not disabled:
		
		%Sound.play()
		for spawner in spawners:
			var bullet = HELPER_20.instantiate()
			bullet.transform = spawner.global_transform
			bullet.build(
				GlobalShooter.SPADE_WHITE,
				bullet_speed + RNG.randf_range(-bullet_speed_range, bullet_speed_range),
				turn_delay   + RNG.randf_range(-turn_delay_range,   turn_delay_range),
				turn_time    + RNG.randf_range(-turn_time_range,    turn_time_range),
				turn_max     + RNG.randf_range(-turn_max_range,     turn_max_range)
			)
			GlobalStage.request_add_object.emit(bullet)
		
		await %Timer.timeout


func disable():
	disabled = true
	
	%Particles.emitting = false
	
	var SunTween = self.create_tween().set_parallel(true)
	SunTween.tween_property(%Sprite, "scale", Vector2.ZERO, 0.8)




func _on_Collider_collider_entered(_other, other_identity):
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()
