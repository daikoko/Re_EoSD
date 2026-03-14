extends Resource
class_name PracticeDifficulty

@export var difficulty_id: GlobalSettings.DIFFICULTY

@export var boss_list:Array[PracticeBoss]

@export_group("Flag")
@export var flag:String




func get_difficulty_name() -> String:
	return GlobalSettings.get_difficulty_string(difficulty_id)


func flag_check() -> bool:
	return GlobalSettings.flag_check(flag)
