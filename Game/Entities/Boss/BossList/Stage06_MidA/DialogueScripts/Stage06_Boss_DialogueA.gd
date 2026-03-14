extends BossEvent_Dialogue

const DIALOGUE_REIMU :=  "ReimuStage06_MidA"
const DIALOGUE_MARISA := "MarisaStage06_MidA"
const DIALOGUE_RIN :=    "RinStage06_MidA"

const BOSS_ID := GlobalSettings.BOSS.SAKUYA
const BOSS := preload("res://Game/Entities/Boss/BossScripts/Boss.tscn")
const SPRITE := preload("res://Game/Entities/Boss/BossResources/Sakuya/Sprite/BossSprite_Sakuya.tres")
const BACKGROUND := preload("res://Game/Entities/Boss/BossResources/Sakuya/Background/Background_BossSakuya.tscn")

const BOSS_IN_POSITION := Vector2(-100, -100)

var Boss:BossObject

signal boss_in_ended




func play_dialogue(EventHandler:Control, BossDict:Dictionary) -> void:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	set_id(BOSS_ID)
	
	Boss = BOSS.instantiate()
	Boss.position = BOSS_IN_POSITION
	Boss.set_sprite(SPRITE)
	Boss.hide()
	BossDict["boss"] = Boss
	GlobalStage.request_add_object.emit(Boss)
	
	var SpellBackground = BACKGROUND.instantiate()
	SpellBackground.hide_background()
	BossDict["background"] = SpellBackground
	EventHandler.add_spell_background(SpellBackground)
	
	if plain:
		GlobalStage.request_dialogue.emit(DIALOGUE_PLAIN, self, true)
	elif GlobalStage.current_player == GlobalSettings.PLAYER.REIMU:
		GlobalStage.request_dialogue.emit(DIALOGUE_REIMU, self, false)
	elif GlobalStage.current_player == GlobalSettings.PLAYER.MARISA:
		GlobalStage.request_dialogue.emit(DIALOGUE_MARISA, self, false)
	elif GlobalStage.current_player == GlobalSettings.PLAYER.RIN:
		GlobalStage.request_dialogue.emit(DIALOGUE_RIN, self, false)


func play_event(event_name:String) -> void:
	if event_name == "boss_in":
		boss_in()
		await self.boss_in_ended
		end_dialogue_event()
	
	if event_name == "end":
		show_bars()
		event_ended.emit()
	
	else:
		end_dialogue_event()




func boss_in() -> void:
	Boss.enable()
	
	var tween:Tween = Boss.create_tween()
	tween.tween_property(Boss, "position", GlobalStage.BOSS_DEFAULT_POSITION, 0.6)
	await tween.finished
	
	boss_in_ended.emit()
