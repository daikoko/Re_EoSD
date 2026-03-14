extends EnemyShooter
class_name EnemyShooter_Laser

@export var lasers:RowData_Column

@export_group("Layout")
@export var layout_spawner_count:int = 1
@export var layout_column_count:int =  1
@export var layout_column_range:float = 360
@export var layout_shot_range:float = 360
@export var layout_distance:float = GlobalShooter.STANDARD_START

@export_group("Fire")
@export var fire_cooldown:float = 1
@export var fire_start_delay:float = 0.1

@export_group("Laser")
@export var laser_duration:float = 5.0
@export var laser_delay_time:float = 1.0
@export var laser_grow_time:float = 0.4
@export var laser_shrink_time:float = 0.2

@export_group("Rotation")
@export_subgroup("Rotation Start")
@export var rotation_start: float = 90
@export var rotation_start_random:bool = true
@export var rotation_start_aim:bool = false
@export_subgroup("Rotation Speed")
@export var rotation_speed: float = 0

@export_group("Modifier")
@export_subgroup("Spawner")
@export var spawner_factor:int = 1
@export var spawner_override:Dictionary = {
	"Easy":    -1,
	"Normal":  -1,
	"Hard":    -1,
	"Lunatic": -1
}




func set_shooter(enemy:Node2D) -> void:
	Main = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			layout_spawner_count, 
			layout_column_count, layout_column_range, 
			layout_shot_range,
			layout_distance
		)
	)
	enemy.add_child(Main)
	Main.deactivated.connect(_on_Main_deactivated)
	
	if rotation_start_random:
		Main.rotation = RNG.randf_range(0, TAU)
	else:
		Main.rotation = deg_to_rad(rotation_start)
	Main.rotation_speed = deg_to_rad(rotation_speed)
	
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
			lasers,
			laser_duration, 
			laser_delay_time, 
			laser_grow_time, 
			laser_shrink_time
		)
		await Main.finished_round
		
		if CoolTimer:
			CoolTimer.start()
			await CoolTimer.timeout


func death_start() -> void:
	if rotation_start_aim:
		Main.rotation = GlobalPlayer.angle_to_player(Main.global_position)
	Main.fire_round(
		lasers,
		laser_duration, 
		laser_delay_time, 
		laser_grow_time, 
		laser_shrink_time
	)
	await Main.finished_round
	
	deactivated.emit()


func copy() -> Resource:
	var copy = self.duplicate() 
	var difficulty_key = GlobalSettings.get_difficulty_key_string(
		GlobalStage.current_difficulty
	)
	
	if spawner_override[difficulty_key] != -1:
		copy.layout_spawner_count = spawner_override[difficulty_key]
	else:
		copy.layout_spawner_count = snappedi(
			layout_spawner_count * GlobalStage.get_shooter_modifier("spawner"), 
			spawner_factor
		)
	
	return copy
