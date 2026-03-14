extends Control

const PRACTICE_DIALOGUE_START := preload("res://Game/Entities/Boss/BossList/Practice/DialogueList/Practice_Boss_DialogueA.tres")
const PRACTICE_DIALOGUE_END   := preload("res://Game/Entities/Boss/BossList/Practice/DialogueList/Practice_Boss_DialogueB.tres")

@export var players:Array[PlayerData] = []
@export var practice_players:Array[PracticePlayer] = []
@export var practice_difficulties:Array[PracticeDifficulty] = []

enum MENU_MODE {
	NEW_GAME,
	CONTINUE,
	EXTRA,
	PHANTASM,
	PRACTICE
}

var menu_mode:int

var current_mode:int
var current_difficulty:int
var current_player:PlayerData
var current_shot:ShotData

signal back
signal selection_finished(save, preserve)




func _ready():
	%SelectPlayer.players = players
	%SelectPractice.practice_players = practice_players
	%SelectPractice.practice_difficulties = practice_difficulties




func load_in(mode:int) -> void:
	self.menu_mode = mode
	if menu_mode == MENU_MODE.NEW_GAME:
		%SelectMode.load_in()
	elif menu_mode == MENU_MODE.EXTRA:
		%SelectDifficulty.load_in(GlobalSettings.SECTION.EXTRA)
	elif menu_mode == MENU_MODE.PRACTICE:
		%SelectPractice.load_in()
	elif menu_mode == MENU_MODE.CONTINUE:
		continue_game()


func load_out() -> void:
	if menu_mode == MENU_MODE.NEW_GAME:
		%SelectMode.load_out()
	elif menu_mode == MENU_MODE.EXTRA:
		%SelectDifficulty.load_out()
	elif menu_mode == MENU_MODE.PRACTICE:
		%SelectPractice.load_out()


func deactivate() -> void:
	%SelectPractice.deactivate()


func reactivate() -> void:
	%SelectPractice.reactivate()




func new_game_main() -> void:
	var save:SaveFile = GlobalSystem.create_save_file()
	save.set_save_file(
		GlobalSettings.SECTION.MAIN,
		current_mode,
		current_difficulty,
		current_player,
		current_shot
	)
	
	GlobalSystem.save_save_file(save)
	selection_finished.emit(save)


func new_game_extra() -> void:
	var save:SaveFile = GlobalSystem.create_save_file()
	save.set_save_file(
		GlobalSettings.SECTION.EXTRA,
		GlobalSettings.MODE.ARCADE,
		current_difficulty,
		current_player,
		current_shot
	)
	
	selection_finished.emit(save)


func new_game_phantasm() -> void:
	var save:SaveFile = GlobalSystem.create_save_file()
	save.set_save_file(
		GlobalSettings.SECTION.PHANTASM,
		GlobalSettings.MODE.ARCADE,
		current_difficulty,
		current_player,
		current_shot
	)
	
	selection_finished.emit(save)


func new_game_practice(practice_series:SeriesData) -> void:
	var save:SaveFile = GlobalSystem.create_save_file()
	save.set_save_file(
		GlobalSettings.SECTION.PRACTICE,
		GlobalSettings.MODE.PRACTICE,
		GlobalSettings.DIFFICULTY.PRACTICE,
		current_player,
		current_shot
	)
	save.set_practice_series(practice_series)
	
	selection_finished.emit(save, true)


func continue_game() -> void:
	var save:SaveFile = GlobalSystem.get_current_save()
	save.set_continue_game()
	
	selection_finished.emit(save)




func _on_SelectMode_back() -> void:
	%SelectMode.load_out()
	back.emit()


func _on_SelectMode_selected(mode) -> void:
	current_mode = mode
	%SelectMode.load_out_next()
	%SelectDifficulty.load_in(menu_mode)


func _on_SelectDifficulty_back():
	%SelectDifficulty.load_out()
	
	if menu_mode == MENU_MODE.NEW_GAME:
		%SelectMode.load_in_back()
	elif menu_mode == MENU_MODE.EXTRA:
		back.emit()
	elif menu_mode == MENU_MODE.PHANTASM:
		back.emit()


func _on_SelectDifficulty_selected(difficulty):
	current_difficulty = difficulty
	%SelectDifficulty.load_out_next()
	
	if current_difficulty == GlobalSettings.DIFFICULTY.PHANTASM:
		menu_mode = MENU_MODE.PHANTASM
	
	if menu_mode == MENU_MODE.NEW_GAME:
		%SelectPlayer.load_in(GlobalSettings.SECTION.MAIN)
	elif menu_mode == MENU_MODE.EXTRA:
		%SelectPlayer.load_in(GlobalSettings.SECTION.EXTRA)
	elif menu_mode == MENU_MODE.PHANTASM:
		%SelectPlayer.load_in(GlobalSettings.SECTION.PHANTASM)


func _on_SelectPlayer_back():
	%SelectPlayer.load_out()
	%SelectDifficulty.load_in_back()


func _on_SelectPlayer_selected(player):
	current_player = player
	%SelectPlayer.load_out_next()
	%SelectShot.load_in(current_player)


func _on_SelectShot_back():
	%SelectShot.load_out()
	%SelectPlayer.load_in_back()


func _on_SelectShot_selected(Shot):
	current_shot = Shot
	
	if menu_mode == MENU_MODE.NEW_GAME:
		new_game_main()
	elif menu_mode == MENU_MODE.EXTRA:
		new_game_extra()
	elif menu_mode == MENU_MODE.PHANTASM:
		new_game_phantasm()


func _on_SelectPractice_back():
	%SelectPractice.load_out()
	back.emit()


func _on_SelectPractice_selected(
		practice_player:PlayerData, 
		practice_shot:ShotData, 
		practice_stage_background:PackedScene,
		practice_boss_sprite:BossSpriteData,
		practice_boss_music:MusicData,
		practice_boss_background:PackedScene,
		practice_boss_spell:BossEvent_Spell,
	):
	
	var start_dialogue = PRACTICE_DIALOGUE_START.duplicate()
	start_dialogue.boss_sprite     = practice_boss_sprite
	start_dialogue.boss_theme      = practice_boss_music
	start_dialogue.boss_background = practice_boss_background
	
	var end_dialogue = PRACTICE_DIALOGUE_END.duplicate()
	
	var spell:BossEvent_Spell = practice_boss_spell.duplicate()
	spell.major_phase = false
	spell.hide_boss = true
	spell.move_boss = false
	spell.show_background = true
	spell.hide_background = true
	spell.Death = DeathData.new()

	var boss = BossData.new([], [
		start_dialogue,
		spell,
		end_dialogue
	])

	var practice_stage:StageData = StageData.new()
	var practice_stage_events:Animation = Animation.new()
	var track_index = practice_stage_events.add_track(Animation.TYPE_METHOD)
	practice_stage_events.track_set_path(track_index, ".")
	practice_stage_events.track_insert_key(track_index, 0.2, {
		"method": "event_boss",
		"args": [boss]
	})
	practice_stage.background = practice_stage_background
	practice_stage.events     = practice_stage_events
	var practice_series = SeriesData.new([practice_stage])

	current_player = practice_player
	current_shot =   practice_shot
	new_game_practice(practice_series)
