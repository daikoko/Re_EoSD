extends BossEvent
class_name BossEvent_Spell

@export var health:float = 50
@export var time:float = 60
@export var base_points:float = 1000
@export var bonus_points:float = 500
@export var Death:DeathData

@export_group("Options")
@export var major_phase:bool
@export var hide_boss:bool
@export var move_boss:bool
@export var show_background:bool
@export var hide_background:bool

@export_group("Special")
@export var timeout:bool
@export var warning:bool

@export_group("ID")
@export var difficulty:GlobalSettings.DIFFICULTY
@export var boss_id:GlobalSettings.BOSS
@export var spell_id:int

var EventHandler:Control
var BossDict:Dictionary
var RNG:RandomNumberGenerator

var stopped:bool = true

signal spell_started




func get_type() -> int:
	return TYPE.SPELL


func prepare(_EventHandler:Control, _BossDict:Dictionary) -> float:
	return 0


func start() -> void:
	pass


func stop() -> void:
	pass


func get_boss_id() -> int:
	return 0 


func get_spell_id() -> int:
	return 0 


func get_boss_text(text) -> String:
	return GlobalSettings.get_boss_text(
		get_boss_id(), 
		text
	)


func get_boss_name() -> String:
	return GlobalSettings.get_boss_text(
		get_boss_id(), 
		"name"
	)


func get_boss_spell() -> String:
	return GlobalSettings.get_boss_text(
		get_boss_id(), 
		"spell_" + GlobalSystem.get_json_num_key(get_spell_id())
	)
