extends Resource
class_name PracticeBoss

@export var boss_id: GlobalSettings.BOSS

@export var boss_sprite_data:BossSpriteData
@export var music_data:MusicData
@export var background_boss:PackedScene
@export var background_stage:PackedScene

@export var spell_list:Array[BossEvent_Spell]

@export_group("Flag")
@export var flag:String




func get_boss_name() -> String:
	return GlobalSettings.get_boss_text(boss_id, "name")


func flag_check() -> bool:
	return GlobalSettings.flag_check(flag)
