extends Node2D

var Boss:BossObject
var EventHandler:Control

const FLASH_TIME_IN := 0.4
const FLASH_TIME_OUT := 0.8

var disabled:bool = false
var disabled_player:bool = false
var disabled_stage:bool = false

var RNG:RandomNumberGenerator




func _ready() -> void:
	%Flash.scale = Vector2.ZERO
	%Flash.modulate.a = 0.8
	
	GlobalStage.stage_reset.connect(_on_GlobalStage_stage_reset)
	GlobalPlayer.player_over.connect(_on_GlobalPlayer_player_over)
	GlobalPlayer.player_continued.connect(_on_GlobalPlayer_player_continued)




func fire(
		set01_bullet:BulletData,
		set01_bullet_speed:float,
		set01_bullet_speed_range:float,
		set01_shooter_spawner_count:int,
		set01_shooter_fire_duration:float,
		set01_shooter_row_count:int,
		set01_shooter_distance_min:float,
		set01_shooter_distance_max:float,
		set01_shooter_distance_range:float,
		
		set02_bullet:BulletData,
		set02_bullet_speed:float,
		set02_shooter_spawner_count:int,
		set02_shooter_point_count:int,
		set02_shooter_shot_range:float,
		set02_shooter_stack_count:int,
		set02_shooter_stack_speed:float,
		set02_shooter_fire_duration:float,
		set02_shooter_distance:float
	) -> void:
	
	if disabled: return
	if disabled_player: return
	if disabled_stage: return
	if GlobalStage.is_current_stage_clear(): return
	
	Boss.hide()
	
	var player_position = GlobalPlayer.get_player_position()
	var boss_position = Boss.global_position
	
	Boss.position = player_position
	GlobalPlayer.set_player_position(boss_position)
	
	EventHandler.stop()
	
	%LayoverSprite.show()
	%LayoverSprite.position = Boss.position
	%Flash.position = Boss.position
	
	%Sound_Stop.play()
	
	flash_in()
	spawn_set01(
		set01_bullet,
		set01_bullet_speed,
		set01_bullet_speed_range,
		set01_shooter_spawner_count,
		set01_shooter_fire_duration,
		set01_shooter_row_count,
		set01_shooter_distance_min,
		set01_shooter_distance_max,
		set01_shooter_distance_range
	)
	await GlobalStage.create_timer_short(self, set01_shooter_fire_duration + 0.017).timeout
	
	spawn_set02(
		set02_bullet,
		set02_bullet_speed,
		set02_shooter_spawner_count,
		set02_shooter_point_count,
		set02_shooter_shot_range,
		set02_shooter_stack_count,
		set02_shooter_stack_speed,
		set02_shooter_fire_duration,
		set02_shooter_distance
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
		bullet_speed_range:float,
		shooter_spawner_count:int,
		shooter_fire_duration:float,
		shooter_row_count:int,
		shooter_distance_min:float,
		shooter_distance_max:float,
		shooter_distance_range:float
	):
	
	%Rotation.global_position = GlobalPlayer.get_player_position()
	
	var distance = shooter_distance_min
	for i in shooter_row_count:
		
		%Sound_Fire.play()
		for j in shooter_spawner_count:
			var random_bullet_speed = RNG.randf_range(
				bullet_speed - bullet_speed_range,
				bullet_speed + bullet_speed_range
			)
			
			%SpawnerMain.global_rotation = GlobalPlayer.angle_to_player(
				%SpawnerMain.global_position
			)
			%SpawnerMain.position.x = RNG.randf_range(
				distance - shooter_distance_range,
				distance + shooter_distance_range
			)
			%Rotation.rotation = RNG.randf_range(0, TAU)
			
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, %SpawnerMain.global_transform,
				random_bullet_speed, 0, 0,
				0,
				1, 0, 8.0
			)
		
		distance += (shooter_distance_max - shooter_distance_min) / shooter_row_count
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_row_count
		).finished


func spawn_set02(
		bullet:BulletData,
		bullet_speed:float,
		shooter_spawner_count:int,
		shooter_point_count:int,
		shooter_shot_range:float,
		shooter_stack_count:int,
		shooter_stack_speed:float,
		shooter_fire_duration:float,
		shooter_distance:float
	):
	
	%Rotation.global_position = GlobalPlayer.get_player_position()
	%SpawnerMain.position.x = shooter_distance
	
	for i in shooter_spawner_count:
		%Sound_Fire.play()
		
		var main_angle = (
			GlobalPlayer.angle_to_player(%SpawnerMain.global_position) - deg_to_rad(
				shooter_shot_range / 2
			)
		)
		var angle_step = deg_to_rad(shooter_shot_range / (shooter_point_count - 1))
		for j in shooter_point_count:
			%SpawnerMain.global_rotation = main_angle
			
			for k in shooter_stack_count:
				GlobalPool.bullet_gravity_spawned.emit(
					bullet, %SpawnerMain.global_transform,
					bullet_speed + (k * shooter_stack_speed), 0, 0,
					0,
					1, 0, 8.0
				)
			
			main_angle += angle_step
		
		%Rotation.rotation += deg_to_rad(360 / shooter_spawner_count) 
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_spawner_count
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
