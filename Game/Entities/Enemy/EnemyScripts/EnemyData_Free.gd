extends EnemyData
class_name EnemyData_Free

const SPAWN_FREE := preload("res://Game/Entities/Enemy/EnemyScripts/EnemyFree.tscn")

@export_group("Free")
@export_subgroup("Position")
@export var position_start:Vector2 = Vector2(340, -20)
@export var position_final:Vector2 = Vector2(340, -20)
@export var random_position:bool = false
@export_subgroup("Enter Angle")
@export var enter_angle_start:float = 90
@export var enter_angle_final:float = 90
@export var random_enter_angle:bool = false
@export_subgroup("Exit Angle")
@export var exit_angle_start:float = -90
@export var exit_angle_final:float = -90
@export var random_exit_angle:bool = false
@export_subgroup("Distance")
@export var distance_start:float = 820
@export var distance_final:float = 820
@export var random_distance:bool = false

var change_position:Vector2
var change_enter:float
var change_exit:float
var change_distance:float

var positions:Array[Vector2]




func initialize(amount:int) -> void:
	var divisor:int
	if amount == 1:
		divisor = 1
	else:
		divisor = amount - 1
	
	change_position = (position_final - position_start) / divisor
	change_enter =    (enter_angle_final - enter_angle_start) / divisor
	change_exit =     (exit_angle_final - exit_angle_start) / divisor
	change_distance = (distance_final - distance_start) / divisor


func get_enemy() -> Node2D:
	return SPAWN_FREE.instantiate()


func add_enemy(enemy:Node2D, count:int) -> void:
	if random_position:
		enemy.position = position_start + ((position_final - position_start) * RNG.randf_range(0, 1))
	else:
		enemy.position = position_start + (change_position * count)
	
	if random_distance:
		enemy.distance_max = RNG.randf_range(distance_start, distance_final)
	else:
		enemy.distance_max = distance_start + (change_distance * count)
	
	var enemy_enter = deg_to_rad(enter_angle_start + (change_enter * count))
	var enemy_exit = deg_to_rad(exit_angle_start + (change_exit * count))
	
	if random_enter_angle:
		enemy_enter = deg_to_rad(
			RNG.randf_range(enter_angle_start, enter_angle_final)
		)
	
	if random_exit_angle:
		enemy_exit = deg_to_rad(
			RNG.randf_range(exit_angle_start, exit_angle_final)
		)
	
	enemy.enter_velocity = Vector2.RIGHT.rotated(enemy_enter) * speed
	enemy.exit_velocity = Vector2.RIGHT.rotated(enemy_exit) * retreat_speed

	GlobalStage.request_add_object.emit(enemy)
