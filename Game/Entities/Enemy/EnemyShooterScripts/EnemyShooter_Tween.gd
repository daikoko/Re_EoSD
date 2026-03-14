extends EnemyShooter
class_name EnemyShooter_Tween

@export var bullets:Array[RowData_Bullet]

@export_group("Layout")
@export var layout_spawner_count:int = 1
@export var layout_shape:ShapeTemplate.SHAPE
@export var layout_shape_scale:Vector2 = Vector2.ONE
@export var layout_distance:float = GlobalShooter.STANDARD_START

@export_group("Fire")
@export var fire_count:int = 5
@export var fire_duration:float = 1
@export var fire_cooldown:float = 1
@export var fire_start_delay:float = 0.1

@export_group("Bullet")
@export var bullet_rotation:float = 0
@export var bullet_rotation_speed:float = 0

@export_group("Tween")
@export var tween_time:float
@export var tween_distance:Curve
@export var tween_rotation:Curve

@export_group("Release")
@export var tween_release_angle:float
@export var tween_release_speed:float
@export var tween_release_aim:bool

@export_group("Double")
@export var tween_double:bool
@export var tween_double_bullets:Array[RowData_Bullet]
@export var tween_flip_interval:int = 1000

@export_group("Rotation")
@export_subgroup("Rotation Start")
@export var rotation_start:float = 90
@export var rotation_start_random:bool = true
@export var rotation_start_aim:bool = false
@export_subgroup("Rotation Speed")
@export var rotation_speed:float = 0
@export_subgroup("Rotation Random")
@export var rotation_random:bool = false

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
@export_subgroup("Shape")
@export var shape_factor:int = 1
@export var shape_override:Dictionary = {
	"Easy":    -1,
	"Normal":  -1,
	"Hard":    -1,
	"Lunatic": -1
}




func set_shooter(enemy:Node2D) -> void:
	Main = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(
			layout_spawner_count,
			layout_shape, 
			layout_shape_scale, 
			layout_distance
		)
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
	
	if tween_distance == null:
		tween_distance = GlobalShooter.make_curve(Vector2(0,GlobalSettings.MAX_DIAGONAL), 
			[
				Vector2.ZERO,
				Vector2(1, GlobalSettings.MAX_DIAGONAL)
			]
		)
	if tween_rotation == null:
		tween_rotation = GlobalShooter.make_curve(Vector2(0, 0),
			[
				Vector2(0, 0), 
				Vector2(1, 0)]
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
			bullet_rotation, bullet_rotation_speed,
			tween_time, tween_distance, tween_rotation, 
			tween_release_speed, 
			tween_release_angle, tween_release_aim,
			tween_double, tween_double_bullets,
			tween_flip_interval
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
		bullet_rotation, bullet_rotation_speed,
		tween_time, tween_distance, tween_rotation, 
		tween_release_speed, 
		tween_release_angle, tween_release_aim,
		tween_double, tween_double_bullets,
		tween_flip_interval
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
	
	if shape_override[difficulty_key] != -1:
		copy.layout_spawner_count = shape_override[difficulty_key]
	else:
		copy.layout_spawner_count = snappedi(
			layout_spawner_count * GlobalStage.get_shooter_modifier("shape"), 
			shape_factor
		)
		
	return copy
