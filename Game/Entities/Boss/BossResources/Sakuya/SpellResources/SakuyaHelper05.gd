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
		set01_shooter_spawner_count:int,
		set01_shooter_column_count:int,
		set01_shooter_column_range:float,
		set01_shooter_fire_duration:float,
		set01_shooter_row_count:int,
		set01_shooter_distance_min:float,
		set01_shooter_distance_max:float,
		
		set02_bullet:BulletData,
		set02_bullet_speed:float,
		set02_shooter_spawner_count:int,
		set02_shooter_column_count:int,
		set02_shooter_column_range:float,
		set02_shooter_fire_duration:float,
		set02_shooter_row_count:int,
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
	
	var set01_start_angle = RNG.randf_range(0, 360)
	var set02_start_angle = set01_start_angle + (
		(float(180) / set01_shooter_column_count)
	)
	
	var distance_total = set01_shooter_distance_max - set01_shooter_distance_min
	var set02_shooter_distance_min = set01_shooter_distance_min + (
		((distance_total) / (set01_shooter_row_count - 1)) / 2
	)
	var set02_shooter_distance_max = set01_shooter_distance_max + (
		((distance_total) / (set01_shooter_row_count - 1)) / 2
	)
	
	flash_in()
	spawn(
		set01_bullet,
		set01_bullet_speed,
		set01_shooter_spawner_count,
		set01_shooter_column_count,
		set01_shooter_column_range,
		set01_shooter_fire_duration,
		set01_start_angle,
		set01_shooter_row_count,
		set01_shooter_distance_min,
		set01_shooter_distance_max,
		false
	)
	await GlobalStage.create_timer_short(self, set01_shooter_fire_duration + 0.05).timeout
	
	spawn(
		set02_bullet,
		set02_bullet_speed,
		set02_shooter_spawner_count,
		set02_shooter_column_count,
		set02_shooter_column_range,
		set02_shooter_fire_duration,
		set02_start_angle,
		set02_shooter_row_count,
		set02_shooter_distance_min,
		set02_shooter_distance_max,
		true
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




func spawn(
		bullet:BulletData,
		bullet_speed:float,
		shooter_spawner_count:int,
		shooter_column_count:int,
		shooter_column_range:float,
		shooter_fire_duration:float,
		shooter_start_angle:float,
		shooter_row_count:int,
		shooter_distance_min:float,
		shooter_distance_max:float,
		reverse:bool
	):
	
	var direction = 0
	if reverse: 
		%SpawnerMain.rotation = deg_to_rad(180)
		direction = -1
	else:      
		%SpawnerMain.rotation = deg_to_rad(0)
		direction = 1
	
	var main_angle = shooter_start_angle - ((shooter_column_range / 2) * direction)
	var angle_spawner_step = shooter_column_range / (shooter_spawner_count - 1)
	var angle_column_step = (
		 (360 - (shooter_column_range * shooter_column_count)) / (shooter_column_count)
	)
	
	for i in shooter_column_count:
		for j in shooter_spawner_count:
			
			%Sound_Fire.play()
			%Rotation.rotation = deg_to_rad(main_angle)
			for k in shooter_row_count:
				var distance = shooter_distance_min + (
					(float(k) / (shooter_row_count - 1)) * (
					(shooter_distance_max - shooter_distance_min))
				)
				
				%SpawnerMain.position.x = distance
				GlobalPool.bullet_gravity_spawned.emit(
					bullet, %SpawnerMain.global_transform,
					bullet_speed, 0, 0,
					0,
					1, 0, 8.0
				)
			
			await self.create_tween().tween_interval(
				shooter_fire_duration / (shooter_spawner_count * shooter_column_count)
			).finished
			
			main_angle += angle_spawner_step * direction
		
		main_angle -= angle_spawner_step * direction
		main_angle += angle_column_step * direction




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
