extends Resource
class_name ShotData
## Contains data for a shot type

@export var id:GlobalSettings.SHOT

@export_group("Shot")
@export var shot:PackedScene
@export var flash:PackedScene

@export_group("Flag")
@export var flag:String


func flag_check() -> bool:
	return GlobalSettings.flag_check(flag)


func get_shot_type() -> String:
	return GlobalSettings.get_shot_text(id, "type")


func get_shot_name() -> String:
	return GlobalSettings.get_shot_text(id, "name")


func get_shot_description() -> String:
	return GlobalSettings.get_shot_text(id, "description")
