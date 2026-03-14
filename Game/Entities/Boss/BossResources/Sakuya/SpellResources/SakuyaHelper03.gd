extends Node2D

var Boss:BossObject
var EventHandler:Control

const SPAWN_TIME := 0.4
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



func fire(
		bullet:BulletData,
		bullet_speed:float,
		shooter_row_count:int,
		shooter_point_count:int,
		shooter_rotation_range:float,
		shooter_fire_distance_min:float,
		shooter_fire_distance_max:float,
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
	spawn(
		bullet,
		bullet_speed,
		shooter_row_count,
		shooter_point_count,
		shooter_rotation_range,
		shooter_fire_distance_min,
		shooter_fire_distance_max,
	)
	
	await GlobalStage.create_timer_short(self, SPAWN_TIME).timeout
	
	flash_out()
	
	await GlobalStage.create_timer_short(self, FLASH_TIME_OUT).timeout
	
	%Sound_Release.play()
	
	%LayoverSprite.hide()
	EventHandler.release_stop()
	
	Boss.show()


func disable():
	disabled = true




func create_self(
		layout_spawner_count:int,
		layout_shot_range:int,
	):
	
	var build_angle = -deg_to_rad(layout_shot_range) / 2
	for i in layout_spawner_count:
		var spawner = Marker2D.new()
		spawner.rotation = build_angle
		%Main.add_child(spawner)
		
		build_angle += deg_to_rad(layout_shot_range) / (layout_spawner_count - 1)


func spawn(
		bullet:BulletData,
		bullet_speed:float,
		shooter_row_count:int,
		shooter_point_count:int,
		shooter_rotation_range:float,
		shooter_fire_distance_min:float,
		shooter_fire_distance_max:float
	) -> void:
	
	%SpawnTimer.wait_time = SPAWN_TIME / shooter_row_count
	%SpawnTimer.start()
	
	var main_distance = 0
	var main_angle = 0
	for i in shooter_row_count:
		main_distance = (
			shooter_fire_distance_max - (
				(float(i) / (shooter_row_count - 1)) *
				(shooter_fire_distance_max - shooter_fire_distance_min)
			)
		)
		
		for j in shooter_point_count:
			main_angle = (
				(GlobalPlayer.angle_to_player(Boss.position) - (
				deg_to_rad(shooter_rotation_range) / 2)) + (
					(float(j) / (shooter_point_count - 1)) *
					deg_to_rad(shooter_rotation_range)
				)
			)
			
			%Main.global_position = Boss.position + (
				Vector2.RIGHT.rotated(main_angle) * main_distance
			)
			%Main.global_rotation = main_angle
			
			for spawner in %Main.get_children():
				GlobalPool.bullet_gravity_spawned.emit(
					bullet, spawner.global_transform,
					bullet_speed, 0, 0,
					0,
					1, 0, 0.1
				)
		
		%Sound_Fire.play()
		await GlobalStage.create_timer_short(self, SPAWN_TIME / shooter_row_count).timeout
	
	%SpawnTimer.stop()


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
