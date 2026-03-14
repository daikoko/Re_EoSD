extends Node2D

var Boss:BossObject
var EventHandler:Control

const FLASH_TIME_IN := 0.4
const FLASH_TIME_OUT := 0.8

var disabled:bool = false
var disabled_player:bool = false
var disabled_stage:bool = false




func _ready() -> void:
	%Flash.scale = Vector2.ZERO
	%Flash.modulate.a = 0.8
	
	GlobalStage.stage_reset.connect(_on_GlobalStage_stage_reset)
	GlobalPlayer.player_over.connect(_on_GlobalPlayer_player_over)
	GlobalPlayer.player_continued.connect(_on_GlobalPlayer_player_continued)



func create_self(
		set02_shooter_spawner_count:int,
		set02_shooter_shot_range:float
	):
	
	var spawn_angle = -deg_to_rad(set02_shooter_shot_range / 2)
	var spawn_angle_step = deg_to_rad(
		set02_shooter_shot_range / (set02_shooter_spawner_count - 1)
	)
	
	for i in set02_shooter_spawner_count:
		var spawner = Marker2D.new()
		spawner.rotation = spawn_angle
		%Set02_SpawnerMain.add_child(spawner)
		
		spawn_angle += spawn_angle_step


func fire(
		set01_bullet:BulletData,
		set01_bullet_speed:float,
		set01_shooter_spawner_count:int,
		set01_shooter_fire_count:int,
		set01_shooter_fire_duration:float,
		set01_shooter_rotation_step:float,
		set01_shooter_distance_min:float,
		set01_shooter_distance_max:float,
		
		set02_bullet:BulletData,
		set02_bullet_speed:float,
		set02_shooter_fire_count:int,
		set02_shooter_fire_duration:float,
		set02_shooter_distance:float,
		set02_shooter_stack_count:int,
		set02_shooter_stack_speed:float
	) -> void:
	
	if disabled: return
	if disabled_player: return
	if disabled_stage: return
	if GlobalStage.is_current_stage_clear(): return
	
	Boss.hide()
	
	EventHandler.stop()
	
	%LayoverSprite.show()
	%LayoverSprite.position = Boss.position
	%Flash.position = Boss.position
	
	%Sound_Stop.play()
	
	flash_in()
	spawn_set01(
		set01_bullet,
		set01_bullet_speed,
		set01_shooter_spawner_count,
		set01_shooter_fire_count,
		set01_shooter_fire_duration,
		set01_shooter_rotation_step,
		set01_shooter_distance_min,
		set01_shooter_distance_max
	)
	
	await GlobalStage.create_timer_short(self, set01_shooter_fire_duration).timeout
	
	spawn_set02(
		set02_bullet,
		set02_bullet_speed,
		set02_shooter_fire_count,
		set02_shooter_fire_duration,
		set02_shooter_distance,
		set02_shooter_stack_count,
		set02_shooter_stack_speed
	)
	
	await GlobalStage.create_timer_short(self, set02_shooter_fire_duration).timeout
	
	flash_out()
	
	await GlobalStage.create_timer_short(self, FLASH_TIME_OUT).timeout
	
	%Sound_Release.play()
	
	%LayoverSprite.hide()
	EventHandler.release_stop()
	
	Boss.show()


func disable():
	disabled = true




func spawn_set01(
		bullet:BulletData,
		bullet_speed:float,
		shooter_spawner_count:int,
		shooter_fire_count:int,
		shooter_fire_duration:float,
		shooter_rotation_step:float,
		shooter_distance_min:float,
		shooter_distance_max:float
	) -> void:
	
	var shooter_distance_step = (
		(shooter_distance_max - shooter_distance_min) / shooter_fire_count
	)
	
	%Set01_SpawnerMain.position.x = shooter_distance_max
	%Set01_RotationFirst.rotation = deg_to_rad(60)
	
	for i in shooter_fire_count:
		%Sound_Fire.play()
		
		for j in shooter_spawner_count:
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, %Set01_SpawnerMain.global_transform,
				bullet_speed, 0, 0,
				0,
				1, 0, 0.1
			)
			
			%Set01_RotationSecond.rotation += deg_to_rad(
				float(360) / shooter_spawner_count
			)
		
		%Set01_SpawnerMain.position.x -= shooter_distance_step
		%Set01_RotationFirst.rotation += deg_to_rad(shooter_rotation_step)
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_fire_count
		).finished


func spawn_set02(
		bullet:BulletData,
		bullet_speed:float,
		shooter_fire_count:int,
		shooter_fire_duration:float,
		shooter_distance:float,
		shooter_stack_count:int,
		shooter_stack_speed:float
	) -> void:
	
	var shooter_rotation_step = 360 / shooter_fire_count
	
	%Set02_SpawnerMain.position.x = shooter_distance
	%Set02_RotationFirst.rotation = deg_to_rad(240)
	
	for i in shooter_fire_count:
		
		%Sound_Fire.play()
		
		for j in shooter_stack_count:
			for spawner in %Set02_SpawnerMain.get_children():
				GlobalPool.bullet_gravity_spawned.emit(
					bullet, spawner.global_transform,
					bullet_speed + (j * shooter_stack_speed), 0, 0,
					0,
					1, 0, 0.1
				)
		
		%Set02_RotationFirst.rotation -= deg_to_rad(shooter_rotation_step)
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_fire_count
		).finished


func flash_in() -> void:
	var FlashTweener = create_tween().set_parallel()
	FlashTweener.tween_property(%Flash, "scale", Vector2.ONE * 12, FLASH_TIME_IN)
	FlashTweener.tween_property(%Flash, "modulate:a", 0.0, FLASH_TIME_IN)


func flash_out() -> void:
	var FlashTweener = create_tween().set_parallel()
	FlashTweener.tween_property(%Flash, "scale", Vector2.ZERO, FLASH_TIME_OUT)
	FlashTweener.tween_property(%Flash, "modulate:a", 0.8, FLASH_TIME_OUT)




func _on_GlobalStage_stage_reset() -> void:
	disabled_stage = true


func _on_GlobalPlayer_player_over() -> void:
	disabled_player = true


func _on_GlobalPlayer_player_continued() -> void:
	disabled_player = false
