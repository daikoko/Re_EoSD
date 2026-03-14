extends BossEvent_Dialogue

const BOSS := preload("res://Game/Entities/Boss/BossScripts/Boss.tscn")

@export var boss_sprite:BossSpriteData
@export var boss_theme:MusicData
@export var boss_background:PackedScene

const BOSS_IN_POSITION := Vector2(-100, -100)


var Boss:BossObject

signal boss_in_ended




func play_dialogue(EventHandler:Control, BossDict:Dictionary) -> void:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	
	Boss = BOSS.instantiate()
	Boss.position = BOSS_IN_POSITION
	Boss.set_sprite(boss_sprite)
	Boss.hide()
	BossDict["boss"] = Boss
	GlobalStage.request_add_object.emit(Boss)
	
	if boss_background != null:
		var SpellBackground = boss_background.instantiate()
		SpellBackground.hide_background()
		BossDict["background"] = SpellBackground
		EventHandler.add_spell_background(SpellBackground)
	
	GlobalStage.request_dialogue.emit(DIALOGUE_PLAIN, self, true)


func play_event(event_name:String) -> void:
	if event_name == "boss_in":
		boss_in()
		await self.boss_in_ended
		end_dialogue_event()
	
	if event_name == "boss_theme":
		GlobalStage.request_music_play.emit(boss_theme)
		end_dialogue_event()
	
	elif event_name == "end":
		show_bars()
		event_ended.emit()
	
	else:
		end_dialogue_event()




func boss_in() -> void:
	Boss.show()
	
	var tween:Tween = Boss.create_tween()
	tween.tween_property(Boss, "position", GlobalStage.BOSS_DEFAULT_POSITION, 0.8)
	await tween.finished
	
	boss_in_ended.emit()
