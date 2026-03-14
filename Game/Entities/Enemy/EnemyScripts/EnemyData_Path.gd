extends EnemyData
class_name EnemyData_Path

const SPAWN_PATH := preload("res://Game/Entities/Enemy/EnemyScripts/EnemyPath.tscn")

@export_group("Path")
@export_range(0,10,1,"or_greater") var path:int = 0




func get_enemy() -> Node2D:
	return SPAWN_PATH.instantiate()


func add_enemy(enemy:Node2D, _count:int) -> void:
	enemy.exit_speed = retreat_speed
	
	GlobalStage.request_add_object_path.emit(enemy, path)
