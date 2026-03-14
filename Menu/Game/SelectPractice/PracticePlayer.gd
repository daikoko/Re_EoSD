extends Resource
class_name PracticePlayer

@export var player_data:PlayerData
@export var shot_data:ShotData

@export_group("Flag")
@export var flag:String




func get_shot_name() -> String:
	return shot_data.get_shot_type()


func flag_check() -> bool:
	return GlobalSettings.flag_check(flag)
