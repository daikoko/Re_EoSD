extends BossEvent_Dialogue

const BOSS_OUT_POSITION := Vector2(780, -100)

var Boss:BossObject

signal boss_out_ended




func play_dialogue(EventHandler:Control, BossDict:Dictionary) -> void:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	
	Boss = BossDict["boss"]
	hide_bars()
	
	GlobalStage.request_dialogue.emit(DIALOGUE_PLAIN, self, true)


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
	tween.tween_property(Boss, "position", BOSS_OUT_POSITION, 1.0)
	await tween.finished
	
	boss_out_ended.emit()
