extends Resource
class_name EndingData

@export var music:MusicData
@export var scenes:Array[Texture]
@export_file("*.json") var dialogue:String




func get_scenes() -> Array[Texture]:
	return scenes


func get_dialogue() -> Dictionary:
	return GlobalSystem.get_json_dict(dialogue)
