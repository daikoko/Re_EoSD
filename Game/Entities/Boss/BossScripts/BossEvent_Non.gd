extends BossEvent
class_name BossEvent_Non

@export var health:float = 50
@export var Death:DeathData

@export_group("Options")
@export var hide_boss:bool
@export var move_boss:bool
@export var show_background:bool
@export var hide_background:bool

@export_group("ID")
@export var difficulty:GlobalSettings.DIFFICULTY
@export var boss_id:GlobalSettings.BOSS

var EventHandler:Control
var BossDict:Dictionary
var RNG:RandomNumberGenerator

var stopped:bool = true

signal non_started




func get_type() -> int:
	return TYPE.NON


func prepare(_EventHandler:Control, _BossDict:Dictionary) -> float:
	return 0


func start() -> void:
	pass


func stop() -> void:
	pass


func get_boss_id() -> int:
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
