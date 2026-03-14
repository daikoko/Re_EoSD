extends Node2D

var Boss:BossObject
var EventHandler:Control

const HELPER_09 := preload("res://Game/Entities/Boss/BossResources/Sakuya/SpellResources/SakuyaHelper09.tscn")

const FLASH_TIME_IN := 0.4
const FLASH_TIME_OUT := 0.8

var set01_spawners:Array = []
var set02_spawners:Array = []
var set03_spawners:Array = []

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




func create_self(
		shooter_width:float,
		
		set01_shooter_line_count:int,
		set01_shooter_fire_count:int,
		
		set02_shooter_shot_range:int,
		set02_shooter_line_count:int,
		set02_shooter_fire_count:int,
		
		set03_shooter_distance:int,
		set03_shooter_line_count:int,
		set03_shooter_fire_count:int,
	):
	
	%Set_Line.width = shooter_width
	
	var pos = Vector2(0, -shooter_width / 2)
	var pos_change = shooter_width / (set01_shooter_line_count - 1)
	for i in set01_shooter_line_count:
		var spawner = HELPER_09.instantiate()
		spawner.set_up(set01_shooter_fire_count)
		spawner.position = pos
		
		%Set01_SpawnerMain.add_child(spawner)
		set01_spawners.append(spawner)
		
		pos.x -= 20
		pos.y += pos_change
	
	var angle = -set02_shooter_shot_range / 2
	var angle_change = set02_shooter_shot_range / (set02_shooter_line_count - 1)
	for i in set02_shooter_line_count:
		var spawner = HELPER_09.instantiate()
		spawner.set_up(set02_shooter_fire_count)
		spawner.rotation = deg_to_rad(angle)
		spawner.position += Vector2.RIGHT.rotated(deg_to_rad(angle)) * 10 * i
		
		%Set02_SpawnerMain.add_child(spawner)
		set02_spawners.append(spawner)
		
		angle += angle_change
	
	var rot = 0
	var rot_change = 360.0 / set03_shooter_line_count
	for i in set03_shooter_line_count:
		var loc = Vector2.RIGHT.rotated(deg_to_rad(rot)) * set03_shooter_distance
		var roc = loc.angle() + (PI / 2)
		
		var spawner = HELPER_09.instantiate()
		spawner.set_up(set03_shooter_fire_count)
		spawner.position = loc
		spawner.rotation = roc
		
		%Set03_Rotation.add_child(spawner)
		set03_spawners.append(spawner)
		
		rot += rot_change


func fire(
		set_phase:int,
		
		set01_bullet:BulletData,
		set01_bullet_speed:float,
		set01_bullet_speed_change:float,
		set01_shooter_line_count:int,
		set01_shooter_fire_count:int,
		set01_shooter_fire_duration:float,
		
		set02_bullet:BulletData,
		set02_bullet_speed:float,
		set02_bullet_speed_change:float,
		set02_shooter_line_count:int,
		set02_shooter_fire_count:int,
		set02_shooter_fire_duration:float,
		
		set03_bullet:BulletData,
		set03_bullet_speed:float,
		set03_shooter_line_count:int,
		set03_shooter_fire_count:int,
		set03_shooter_fire_duration:float,
		
		set04_bullet:BulletData,
		set04_bullet_speed:float,
		set04_shooter_spawner_count:int,
		set04_shooter_fire_count:int,
		set04_shooter_fire_duration:float,
		set04_shooter_distance:float
	) -> void:
	
	if disabled: return
	
	set_location()
	%Set_Line.default_color = Color(1,1,1,0.6)
	await Boss.create_tween().tween_interval(0.07).finished
	%Set_Line.default_color = Color(1,1,1,0)
	await Boss.create_tween().tween_interval(0.07).finished
	%Set_Line.default_color = Color(1,1,1,0.6)
	await Boss.create_tween().tween_interval(0.07).finished
	%Set_Line.default_color = Color(1,1,1,0)
	await Boss.create_tween().tween_interval(0.07).finished
	%Set_Line.default_color = Color(1,1,1,0.6)
	await Boss.create_tween().tween_interval(0.07).finished
	%Set_Line.default_color = Color(1,1,1,0)
	await Boss.create_tween().tween_interval(0.07).finished
	%Set_Line.default_color = Color(1,1,1,0.6)
	await Boss.create_tween().tween_interval(0.07).finished
	%Set_Line.default_color = Color(1,1,1,0)
	await Boss.create_tween().tween_interval(0.07).finished
	
	if disabled: return
	if disabled_player: return
	if disabled_stage: return
	if GlobalStage.is_current_stage_clear(): return
	
	var previous_position = %Set_Rotation.global_transform
	Boss.position = Vector2(
		RNG.randf_range(40, 640),
		RNG.randf_range(80, 300)
	)
	%Set_Rotation.global_transform = previous_position
	
	Boss.hide()
	EventHandler.stop()
	%LayoverSprite.show()
	%LayoverSprite.position = Boss.position
	%Flash.position = Boss.position
	%Sound_Stop.play()
	
	flash_in()
	if set_phase == 0:
		spawn_set01(
			set01_bullet,
			set01_bullet_speed,
			set01_bullet_speed_change,
			set01_shooter_line_count,
			set01_shooter_fire_count,
			set01_shooter_fire_duration
		)
	else:
		spawn_set02(
			set02_bullet,
			set02_bullet_speed,
			set02_bullet_speed_change,
			set02_shooter_line_count,
			set02_shooter_fire_count,
			set02_shooter_fire_duration
		)
	spawn_set03(
		set03_bullet,
		set03_bullet_speed,
		set03_shooter_line_count,
		set03_shooter_fire_count,
		set03_shooter_fire_duration
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
	spawn_set04(
		set04_bullet,
		set04_bullet_speed,
		set04_shooter_spawner_count,
		set04_shooter_fire_count,
		set04_shooter_fire_duration,
		set04_shooter_distance
	)
	await GlobalStage.create_timer_short(self, set04_shooter_fire_duration).timeout
	
	flash_out()
	await GlobalStage.create_timer_short(self, FLASH_TIME_OUT).timeout
	
	%Sound_Release.play()
	%LayoverSprite.hide()
	EventHandler.release_stop()
	Boss.show()


func disable():
	disabled = true




func set_location():
	var location = Vector2(
		RNG.randf_range(160, 520), 390
	)
	
	var lower_bound = 0
	if location.x < 340:
		lower_bound = 45 * ((340 - location.x) / 220)
	var upper_bound = 0
	if location.x > 340:
		upper_bound = 45 * ((location.x - 340) / 220)
	var angle = RNG.randf_range(
		90 - lower_bound,
		90 + upper_bound
	)
	
	%Set_Rotation.global_position = location
	%Set_Rotation.global_rotation = deg_to_rad(angle)


func spawn_set01(
		bullet:BulletData,
		bullet_speed:float,
		bullet_speed_change:float,
		shooter_line_count:int,
		shooter_fire_count:int,
		shooter_fire_duration:float
	):
	
	for i in shooter_line_count:
		set01_spawners[i].reset()
	
	for i in shooter_fire_count:
		%Sound_Fire.play()
		
		for j in shooter_line_count:
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, set01_spawners[j].locate_next(),
				bullet_speed + (j * bullet_speed_change), 0, 0,
				0,
				1, 0, 8.0
			)
		
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_fire_count
		).finished


func spawn_set02(
		bullet:BulletData,
		bullet_speed:float,
		bullet_speed_change:float,
		shooter_line_count:int,
		shooter_fire_count:int,
		shooter_fire_duration:float
	):
	
	for i in shooter_line_count:
		set02_spawners[i].reset()
	
	for i in shooter_fire_count:
		%Sound_Fire.play()
		
		for j in shooter_line_count:
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, set02_spawners[j].locate_next(),
				bullet_speed + (j * bullet_speed_change), 0, 0,
				0,
				1, 0, 8.0
			)
		
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_fire_count
		).finished


func spawn_set03(
		bullet:BulletData,
		bullet_speed:float,
		shooter_line_count:int,
		shooter_fire_count:int,
		shooter_fire_duration:float
	):
	
	%Set03_Rotation.rotation = RNG.randf_range(0, TAU)
	
	for i in shooter_line_count:
		set03_spawners[i].reset()
	
	for i in shooter_fire_count:
		%Sound_Fire.play()
		
		for j in shooter_line_count:
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, set03_spawners[j].locate_next(),
				bullet_speed, 0, 0,
				0,
				1, 0, 8.0
			)
		
		await self.create_tween().tween_interval(
			shooter_fire_duration / shooter_fire_count
		).finished




func spawn_set04(
		bullet:BulletData,
		bullet_speed:float,
		shooter_spawner_count:int,
		shooter_fire_count:int,
		shooter_fire_duration:float,
		shooter_distance:float
	):
	
	%Set03_Rotation.rotation = RNG.randf_range(0, TAU)
	
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
		angle_array.append(RNG.randf_range(0, TAU))
	
	for i in shooter_spawner_count:
		%Sound_Fire.play()
		
		for j in shooter_fire_count:
			%Set04_Rotation.global_position = position_array[j]
			%Set04_Rotation.global_rotation = deg_to_rad(angle_array[j])
			%Set04_SpawnerMain.position.x = shooter_distance
			
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, %Set04_SpawnerMain.global_transform,
				bullet_speed, 0, 0,
				0,
				1, 0, 8.0
			)
			
			var angle = angle_array[j]
			angle_array[j] = angle + (360.0 / (shooter_spawner_count - 1))
		
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
