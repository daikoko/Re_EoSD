extends CanvasLayer

const REIMU_GOOD_END := preload("res://Game/Main/Ending/EndingList/Ending_ReimuGood.tres")
const REIMU_BAD_END  := preload("res://Game/Main/Ending/EndingList/Ending_ReimuBad.tres")

const MARISA_GOOD_END := preload("res://Game/Main/Ending/EndingList/Ending_MarisaGood.tres")
const MARISA_BAD_END  := preload("res://Game/Main/Ending/EndingList/Ending_MarisaBad.tres")

const RIN_GOOD_END := preload("res://Game/Main/Ending/EndingList/Ending_RinGood.tres")
const RIN_BAD_END  := preload("res://Game/Main/Ending/EndingList/Ending_RinBad.tres")

const GOOD_END_THEME := preload("res://Game/Main/Ending/EndingResources/_General/Music_16.tres")
const BAD_END_THEME  := preload("res://Game/Main/Ending/EndingResources/_General/Music_17.tres")

var active_to_user:bool = false

var scenes:Array[Texture]
var scenes_index:int

var dialogue:Dictionary
var dialogue_keys:Array
var dialogue_index:int

signal new_text
signal user_next
signal ending_finished




func _ready():
	visible = true
	active_to_user = false


func _process(_delta):
	if Input.is_action_pressed("dialogue_skip") and active_to_user:
		user_next.emit()


func _input(event):
	if event.is_action_pressed("dialogue_next") and active_to_user:
		user_next.emit()




func start(save:SaveFile) -> void:
	await get_tree().process_frame
	
	%EndingCover.screen_cover_in()
	await %EndingCover.screen_in
	
	GlobalStage.request_music_stop.emit()
	
	var data = get_ending(save)
	if data == null:
		ending_finished.emit()
		return
	
	scenes = data.get_scenes()
	dialogue = data.get_dialogue()
	dialogue_keys = dialogue.keys()
	
	scenes_index = -1
	dialogue_index = -1
	
	var DelayTimer = GlobalStage.create_timer(self, 1.0)
	DelayTimer.start()
	await DelayTimer.timeout
	
	next_dialogue()
	await new_text
	
	%EndingCover.screen_cover_out()
	await %EndingCover.screen_out
	
	DelayTimer.wait_time = 0.4
	DelayTimer.start()
	await DelayTimer.timeout
	DelayTimer.queue_free()
	
	%TextHandler.show_panel()
	await %TextHandler.text_shown
	
	active_to_user = true




func next_dialogue() -> void:
	dialogue_index += 1
	if dialogue_index == dialogue_keys.size():
		end_dialogue()
		return
	elif dialogue_index > dialogue_keys.size():
		return
	
	var current:Dictionary = dialogue[dialogue_keys[dialogue_index]]
	match current["type"]:
		"text":
			play_text(current)
		"scene":
			play_scene()
			next_dialogue()
		"music_play":
			play_music(current)
			next_dialogue()
		"music_stop":
			stop_music()
			next_dialogue()


func end_dialogue() -> void:
	%TextHandler.hide_panel()
	await %TextHandler.text_hidden
	
	%EndingCover.screen_cover_in()
	await %EndingCover.screen_in
	
	%Music.stop()
	
	ending_finished.emit()


func play_text(section:Dictionary) -> void:
	%TextHandler.new_text(
		section["name"], 
		section["text"].replace("\n", " ")
	)
	await  get_tree().process_frame
	
	new_text.emit()
	await user_next
	
	next_dialogue()


func play_scene() -> void:
	if scenes_index < scenes.size():
		scenes_index += 1
		%SceneHandler.change_scene(scenes[scenes_index])


func play_music(section:Dictionary) -> void:
	var music_key = section["music"]
	var music = null
	
	if music_key == "good_end_theme": music = GOOD_END_THEME
	if music_key == "bad_end_theme":  music = BAD_END_THEME
	
	%Music.set_music(music)
	%Music.play()


func stop_music() -> void:
	%Music.stop()


func get_ending(save:SaveFile) -> EndingData:
	var mode    = save.game_mode
	var section = GlobalStage.current_section
	var player  = GlobalStage.current_player
	var single  = save.continues == GlobalSettings.STARTING_CONTINUES_MAIN
	
	if section == GlobalSettings.SECTION.EXTRA:    return null
	if section == GlobalSettings.SECTION.PHANTASM: return null
	
	if player == GlobalSettings.PLAYER.REIMU:
		if mode == GlobalSettings.MODE.CASUAL:     return REIMU_GOOD_END
		if not single:                             return REIMU_BAD_END
		if single:                                 return REIMU_GOOD_END
	if player == GlobalSettings.PLAYER.MARISA:
		if mode == GlobalSettings.MODE.CASUAL:     return MARISA_GOOD_END
		if not single:                             return MARISA_BAD_END
		if single:                                 return MARISA_GOOD_END
	if player == GlobalSettings.PLAYER.RIN:
		if mode == GlobalSettings.MODE.CASUAL:     return RIN_GOOD_END
		if not single:                             return RIN_BAD_END
		if single:                                 return RIN_GOOD_END
	
	return null
