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
		set01_bullet_speed_change:float,
		set01_shooter_spawner_count:int,
		set01_shooter_column_count:int,
		set01_shooter_column_range:float,
		set01_shooter_fire_count:float,
		set01_shooter_fire_duration:float,
		set01_shooter_distance:float,
		set01_shooter_distance_change:float,
		
		set02_bullet:BulletData,
		set02_bullet_speed:float,
		set02_shooter_spawner_count:int,
		set02_shooter_shot_range:float,
		set02_shooter_fire_count:float,
		set02_shooter_fire_duration:float,
		set02_shooter_distance:float,
		
		set03_bullet:BulletData,
		set03_bullet_speed:float,
		set03_bullet_speed_range:float,
		set03_shooter_spawn_count:float,
		set03_shooter_fire_count:float,
		set03_shooter_fire_duration:float,
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
		set01_bullet_speed_change,
		set01_shooter_spawner_count,
		set01_shooter_column_count,
		set01_shooter_column_range,
		set01_shooter_fire_count,
		set01_shooter_fire_duration,
		set01_shooter_distance,
		set01_shooter_distance_change,
	)
	await GlobalStage.create_timer_short(self, set01_shooter_fire_duration).timeout
	
	flash_out()
	await GlobalStage.create_timer_short(self, FLASH_TIME_OUT).timeout
	
	%LayoverSprite.hide()
	EventHandler.release_stop()
	Boss.show()
	await GlobalStage.create_timer_short(self, 0.6).timeout
	
	if disabled: return
	if disabled_player: return
	if disabled_stage: return
	if GlobalStage.is_current_stage_clear(): return
	
	Boss.position = Vector2(
		RNG.randf_range(40, 640),
		RNG.randf_range(80, 300)
	)
	
	Boss.hide()
	EventHandler.stop()
	%LayoverSprite.show()
	%LayoverSprite.position = Boss.position
	%Flash.position = Boss.position
	%Sound_Stop.play()
	
	flash_in()
	spawn_set02(
		set02_bullet,
		set02_bullet_speed,
		set02_shooter_spawner_count,
		set02_shooter_shot_range,
		set02_shooter_fire_count,
		set02_shooter_fire_duration,
		set02_shooter_distance,
	)
	await GlobalStage.create_timer_short(self, set02_shooter_fire_duration).timeout
	
	flash_out()
	await GlobalStage.create_timer_short(self, FLASH_TIME_OUT).timeout
	
	%LayoverSprite.hide()
	EventHandler.release_stop()
	Boss.show()
	await GlobalStage.create_timer_short(self, 0.6).timeout
	
	if disabled: return
	if disabled_player: return
	if disabled_stage: return
	if GlobalStage.is_current_stage_clear(): return
	
	Boss.position = Vector2(
		RNG.randf_range(40, 640),
		RNG.randf_range(80, 300)
	)
	
	Boss.hide()
	EventHandler.stop()
	%LayoverSprite.show()
	%LayoverSprite.position = Boss.position
	%Flash.position = Boss.position
	%Sound_Stop.play()
	
	flash_in()
	spawn_set03(
		set03_bullet,
		set03_bullet_speed,
		set03_bullet_speed_range,
		set03_shooter_spawn_count,
		set03_shooter_fire_count,
		set03_shooter_fire_duration,
	)
	await GlobalStage.create_timer_short(self, set03_shooter_fire_duration).timeout
	
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
		bullet_speed_change:float,
		shooter_spawner_count:int,
		shooter_column_count:int,
		shooter_column_range:float,
		shooter_fire_count:float,
		shooter_fire_duration:float,
		shooter_distance:float,
		shooter_distance_change:float,
	):
	
	var start_angle = RNG.randf_range(0, TAU)
	var column_step = (360 - (shooter_column_range * shooter_column_count)) / shooter_column_count
	var spawner_step = shooter_column_range / (shooter_column_count - 1)
	
	%Set01_SpawnerMain.position.x = shooter_distance
	for i in shooter_fire_count:
		%Sound_Fire.play()
		
		%Set01_Rotation.rotation = deg_to_rad(start_angle)
		for j in shooter_column_count:
			for k in shooter_spawner_count:
				GlobalPool.bullet_gravity_spawned.emit(
					bullet, %Set01_SpawnerMain.global_transform,
					bullet_speed + (i * bullet_speed_change), 0, 0,
					0,
					1, 0, 8.0
				)
				
				%Set01_Rotation.rotation += deg_to_rad(spawner_step)
			
			%Set01_Rotation.rotation -= deg_to_rad(spawner_step)
			%Set01_Rotation.rotation += deg_to_rad(column_step)
		
		%Set01_SpawnerMain.position.x += shooter_distance_change
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_fire_count
		).finished


func spawn_set02(
		bullet:BulletData,
		bullet_speed:float,
		shooter_spawner_count:int,
		shooter_shot_range:float,
		shooter_fire_count:float,
		shooter_fire_duration:float,
		shooter_distance:float,
	):
	
	var position_array = []
	var angle_array = []
	for i in shooter_fire_count:
		
		var rand_pos = GlobalPlayer.get_player_position()
		while (GlobalPlayer.distance_to_player(rand_pos) < 250):
			rand_pos = Vector2(
				RNG.randf_range(20, 660),
				RNG.randf_range(2, 760)
			)
		position_array.append(rand_pos)
		
		angle_array.append(
			GlobalPlayer.angle_to_player_degrees(position_array[i]) - (
			shooter_shot_range / 2) + (
			RNG.randf_range(-0.4, 0.4))
		)
	
	for i in shooter_spawner_count:
		%Sound_Fire.play()
		
		for j in shooter_fire_count:
			%Set02_Rotation.global_position = position_array[j]
			%Set02_Rotation.global_rotation = deg_to_rad(angle_array[j])
			%Set02_SpawnerMain.position.x = shooter_distance
			
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, %Set02_SpawnerMain.global_transform,
				bullet_speed, 0, 0,
				0,
				1, 0, 8.0
			)
			
			var angle = angle_array[j]
			angle_array[j] = angle + (shooter_shot_range / (shooter_spawner_count - 1))
		
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_fire_count
		).finished


func spawn_set03(
		bullet:BulletData,
		bullet_speed:float,
		bullet_speed_range:float,
		shooter_spawn_count:float,
		shooter_fire_count:float,
		shooter_fire_duration:float,
	):
	
	for i in shooter_fire_count:
		%Sound_Fire.play()
		
		for j in shooter_spawn_count:
			var rand_pos = GlobalPlayer.get_player_position()
			while (GlobalPlayer.distance_to_player(rand_pos) < 100):
				rand_pos = Vector2(
					RNG.randf_range(5, 675),
					RNG.randf_range(5, 775)
				)
			%Set03_Rotation.global_position = rand_pos
			%Set03_Rotation.global_rotation = RNG.randf_range(0, TAU)
			
			var random_speed = RNG.randf_range(
				bullet_speed - bullet_speed_range,
				bullet_speed + bullet_speed_range
			)
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, %Set03_Rotation.global_transform,
				random_speed, 0, 0,
				0,
				1, 0, 8.0
			)
		
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
