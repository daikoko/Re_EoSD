extends BossEvent
class_name BossEvent_Dialogue

const DIALOGUE_PLAIN := "Plain"

@export_group("Options")
@export var plain:bool = false

var EventHandler:Control
var BossDict:Dictionary

var boss_id:int

signal dialogue_event_ended




func get_type() -> int:
	return TYPE.DIALOGUE


func set_id(boss_id:int) -> void:
	self.boss_id = boss_id


func end_dialogue_event() -> void:
	await GlobalStage.get_tree().process_frame
	dialogue_event_ended.emit()


func show_bars() -> void:
	EventHandler.show_bars()
	EventHandler.count_spells()
	EventHandler.set_boss_name(
		GlobalSettings.get_boss_text(boss_id, "name")
	)


func hide_bars() -> void:
	EventHandler.hide_bars()
