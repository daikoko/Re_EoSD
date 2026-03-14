extends Resource
class_name MusicData

@export var id:int
@export var name:String
@export var music:AudioStreamOggVorbis

@export_group("Flag")
@export var flag:String




func get_music_name() -> String:
	return GlobalSettings.get_music_text(id)


func flag_check() -> bool:
	return GlobalSettings.flag_check(flag)
