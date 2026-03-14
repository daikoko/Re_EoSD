extends BossEvent_Dialogue

const DIALOGUE_REIMU  := "ReimuStageExtra_End"
const DIALOGUE_MARISA := "MarisaStageExtra_End"
const DIALOGUE_RIN    := "RinStageExtra_End"

const BOSS_ID := GlobalSettings.BOSS.FLANDRE

const BOSS_OUT_POSITION := Vector2(780, -100)

var Boss:BossObject

signal boss_out_ended




func play_dialogue(EventHandler:Control, BossDict:Dictionary) -> void:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	set_id(BOSS_ID)
	
	Boss = BossDict["boss"]
	
	hide_bars()
	
	if plain:
		GlobalStage.request_dialogue.emit(DIALOGUE_PLAIN, self, true)
	elif GlobalStage.current_player == GlobalSettings.PLAYER.REIMU:
		GlobalStage.request_dialogue.emit(DIALOGUE_REIMU, self, true)
	elif GlobalStage.current_player == GlobalSettings.PLAYER.MARISA:
		GlobalStage.request_dialogue.emit(DIALOGUE_MARISA, self, true)
	elif GlobalStage.current_player == GlobalSettings.PLAYER.RIN:
		GlobalStage.request_dialogue.emit(DIALOGUE_RIN, self, true)


func play_event(event_name:String) -> void:
	if event_name == "boss_out":
		boss_out()
		await self.boss_out_ended
		end_dialogue_event()
	
	elif event_name == "end":
		event_ended.emit()
	
	else:
		end_dialogue_event()




func boss_out() -> void:
	var tween:Tween = Boss.create_tween()
	tween.tween_interval(0.6)
	tween.tween_property(Boss, "position", BOSS_OUT_POSITION, 0.4)
	await tween.finished
	
	boss_out_ended.emit()
