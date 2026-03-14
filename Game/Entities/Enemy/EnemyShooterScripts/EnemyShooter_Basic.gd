extends EnemyShooter
class_name EnemyShooter_Basic

@export var bullets:Array[RowData_Column]

@export_group("Layout")
@export var layout_spawner_count:int = 1
@export var layout_column_count:int =  1
@export var layout_column_range:float = 360
@export var layout_shot_range:float = 360
@export var layout_distance:float = GlobalShooter.STANDARD_START
@export var layout_random:bool = false

@export_group("Fire")
@export var fire_count:int = 5
@export var fire_duration:float = 1
@export var fire_cooldown:float = 1
@export var fire_start_delay:float = 0.1

@export_group("Bullet")
@export var bullet_speed:float = 200
@export var bullet_speed_range:float = 0
@export var bullet_rotation:float = 0
@export var bullet_rotation_speed:float = 0
@export var bullet_gravity:float = 0

@export_group("Spawn")
@export var spawn_row_speed:float = 0
@export var spawn_spawner_speed:float = 0
@export var spawn_stack_count:int = 1
@export var spawn_stack_speed:float = 0

@export_group("Rotation")
@export_subgroup("Rotation Start")
@export var rotation_start: float = 90
@export var rotation_start_random:bool = true
@export var rotation_start_aim:bool = false
@export_subgroup("Rotation Speed")
@export var rotation_speed: float = 0
@export_subgroup("Rotation Random")
@export var rotation_random:bool = false
@export var rotation_random_range:Vector2 = Vector2(0, 360)

@export_group("Flash")
@export var flash_scale:float = 2.0
@export var flash_time:float = 0.2
@export var immunity_time:float = 0.1

@export_group("Modifier")
@export_subgroup("Fire")
@export var fire_factor:int = 1
@export var fire_override:Dictionary = {
	"Easy":    -1,
	"Normal":  -1,
	"Hard":    -1,
	"Lunatic": -1
}
@export_subgroup("Spawner")
@export var spawner_factor:int = 1
@export var spawner_override:Dictionary = {
	"Easy":    -1,
	"Normal":  -1,
	"Hard":    -1,
	"Lunatic": -1
}




func set_shooter(enemy:Node2D) -> void:
	Main = GlobalShooter.create_basic_shooter(
		layout_spawner_count, 
		layout_column_count, layout_column_range, 
		layout_shot_range,
		layout_distance, 
		layout_random, 
		RNG
	)
	enemy.add_child(Main)
	Main.deactivated.connect(_on_Main_deactivated)
	
	Main.RNG = RNG
	if rotation_start_random:
		Main.rotation = RNG.randf_range(0, TAU)
	else:
		Main.rotation = deg_to_rad(rotation_start)
	Main.rotation_speed = deg_to_rad(rotation_speed)
	Main.rotation_random = rotation_random
	Main.rotation_random_range = rotation_random_range * (TAU / 360)
	Main.flash_scale = flash_scale
	Main.flash_time = flash_time
	Main.immunity_time = immunity_time
	
	StartTimer = GlobalStage.create_timer(
		enemy, 
		fire_start_delay
	)
	CoolTimer = GlobalStage.create_timer(
		enemy, 
		fire_cooldown
	)
	
	active = true


func start() -> void:
	StartTimer.start()
	await StartTimer.timeout
	
	while active:
		if rotation_start_aim:
			Main.rotation = GlobalPlayer.angle_to_player(Main.global_position)
		Main.fire_round(
			bullets, 
			fire_count, fire_duration, 
			bullet_speed, bullet_speed_range,
			bullet_rotation, bullet_rotation_speed,
			bullet_gravity,
			spawn_row_speed, spawn_spawner_speed,
			spawn_stack_count, spawn_stack_speed
		)
		await Main.finished_round
		
		if CoolTimer:
			CoolTimer.start()
			await CoolTimer.timeout


func death_start() -> void:
	if rotation_start_aim:
		Main.rotation = GlobalPlayer.angle_to_player(Main.global_position)
	Main.fire_round(
		bullets, 
		fire_count, fire_duration, 
		bullet_speed, bullet_speed_range,
		bullet_rotation, bullet_rotation_speed,
		bullet_gravity,
		spawn_row_speed, spawn_spawner_speed,
		spawn_stack_count, spawn_stack_speed
	)
	await Main.finished_round
	
	deactivated.emit()


func copy() -> Resource:
	var copy = self.duplicate() 
	var difficulty_key = GlobalSettings.get_difficulty_key_string(
		GlobalStage.current_difficulty
	)
	
	if fire_override[difficulty_key] != -1:
		copy.fire_count = fire_override[difficulty_key]
	else:
		copy.fire_count = snappedi(
			fire_count * GlobalStage.get_shooter_modifier("fire"), 
			fire_factor
		)
	
	if spawner_override[difficulty_key] != -1:
		copy.layout_spawner_count = spawner_override[difficulty_key]
	else:
		copy.layout_spawner_count = snappedi(
			layout_spawner_count * GlobalStage.get_shooter_modifier("spawner"), 
			spawner_factor
		)
	
	return copy
