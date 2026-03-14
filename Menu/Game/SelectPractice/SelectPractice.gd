extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"
const SELECT_PRACTICE_BUTTON := preload("res://Menu/Game/SelectPractice/SelectPracticeButtton.tscn")

@export var practice_players:Array[PracticePlayer] = []
@export var practice_difficulties:Array[PracticeDifficulty] = []
@export var practice_bosses:Array[PracticeBoss] = []
@export var practice_spells:Array[BossEvent_Spell] = []

var valid_practice_difficulties:Array[PracticeDifficulty] = []

var practice_boss_index:int = 0
var valid_practice_bosses:Array[PracticeBoss] = []

enum MODE {
	PLAYER,
	DIFFICULTY,
	BOSS
}
var mode:int

var main_active:bool = true
var menu_active:bool = false
var FocusTargetPlayer:Control
var FocusTargetDifficulty:Control
var FocusTargetBoss:Control
var FocusTargetDecoy:Control

var current_practice_player:PlayerData
var current_practice_shot:ShotData
var current_practice_stage_background:PackedScene
var current_practice_boss_sprite:BossSpriteData
var current_practice_boss_music:MusicData
var current_practice_boss_background:PackedScene
var current_practice_boss_spell:BossEvent_Spell

signal back
signal selected(
	practice_player:PlayerData, 
	practice_shot:ShotData, 
	practice_stage_background:PackedScene,
	practice_boss_sprite:BossSpriteData,
	practice_boss_music:MusicData,
	practice_boss_background:PackedScene,
	practice_boss_spell:BossEvent_Spell
)




func _ready():
	toggle_buttons(false)
	place_text()
	
	FocusTargetDecoy = %Decoy


func _process(_delta:float) -> void:
	if !Input.is_action_pressed("ui_left"):
		%Left.button_pressed = false
	if !Input.is_action_pressed("ui_right"):
		%Right.button_pressed = false


func _input(event):
	if main_active == false or menu_active == false:
		return
	
	if mode == MODE.PLAYER:
		if event.is_action_pressed("menu_escape"):
			back.emit()
			%Sound_Select04.play()
	
	elif mode == MODE.DIFFICULTY:
		if event.is_action_pressed("menu_escape"):
			load_out_difficulty()
			%Sound_Select04.play()
	
	elif mode == MODE.BOSS:
		if event.is_action_pressed("menu_escape"):
			load_out_boss()
			%Sound_Select04.play()
		elif event.is_action_pressed("ui_left"):
			if ! change_index_boss(-1): 
				return
			%Left.button_pressed = true
			%Sound_Select02.play()
		elif event.is_action_pressed("ui_right"):
			if ! change_index_boss(1): return
			%Right.button_pressed = true
			%Sound_Select02.play()




func load_in() -> void:
	mode = MODE.PLAYER
	
	load_players()
	
	%Animator.play("Player_Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetPlayer.grab_focus()


func load_out() -> void:
	menu_active = false
	%Decoy.grab_focus()
	
	%Animator.play("Player_Load_Out")


func load_in_difficulty() -> void:
	mode = MODE.DIFFICULTY
	
	validate_difficulties()
	load_difficulty()
	
	toggle_buttons(false)
	%Decoy.grab_focus()
	%Animator.play("Difficulty_Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetDifficulty.grab_focus()


func load_out_difficulty() -> void:
	mode = MODE.PLAYER
	menu_active = false
	%Decoy.grab_focus()
	
	%Animator.play("Difficulty_Load_Out")
	await %Animator.animation_finished
	
	for child in %PlayersList.get_children():
		child.button_pressed = false
	
	toggle_buttons(true)
	FocusTargetPlayer.grab_focus()


func load_in_boss() -> void:
	mode = MODE.BOSS
	
	validate_bosses()
	set_index_boss()
	
	toggle_buttons(false)
	%Decoy.grab_focus()
	%Animator.play("Boss_Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetBoss.grab_focus()


func load_out_boss() -> void:
	mode = MODE.DIFFICULTY
	menu_active = false
	%Decoy.grab_focus()
	
	%Animator.play("Boss_Load_Out")
	await %Animator.animation_finished
	
	for child in %DifficultyList.get_children():
		child.button_pressed = false
	
	toggle_buttons(true)
	FocusTargetDifficulty.grab_focus()


func deactivate() -> void:
	main_active = false


func reactivate() -> void:
	change_index_boss(0)
	
	main_active = true
	menu_active = true
	set_process(true)
	
	for child in %SpellList.get_children():
		child.button_pressed = false



func toggle_buttons(enable:bool) -> void:
	menu_active = enable
	
	if enable == false:
		%Left.disabled = true
		%Right.disabled = true
	
	else:
		if valid_practice_bosses.size() < 2:
			%Left.disabled = true
			%Right.disabled = true
		else:
			%Left.disabled = false
			%Right.disabled = false


func place_text() -> void:
	# var text_dict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	pass




func load_players() -> void:
	for child in %PlayersList.get_children():
		child.queue_free()
	
	var prev_button:Control = %Title
	for i in practice_players.size():
		var practice_player = practice_players[i]
		var button = SELECT_PRACTICE_BUTTON.instantiate()
		var data:Dictionary = {
			"player": practice_player.player_data,
			"shot":   practice_player.shot_data
		}
		
		%PlayersList.add_child(button)
		button.set_option_name(practice_player.get_shot_name())
		button.set_option_data(data)
		button.data_return.connect(_on_PlayerButton_pressed)
		
		if i == 0:
			FocusTargetPlayer = button
		else:
			prev_button.focus_neighbor_bottom = prev_button.get_path_to(button)
			button.focus_neighbor_top = button.get_path_to(prev_button)
		prev_button = button




func load_difficulty() -> void:
	for child in %DifficultyList.get_children():
		child.queue_free()
	
	var prev_button:Control = %Title
	for i in valid_practice_difficulties.size():
		var practice_difficulty = valid_practice_difficulties[i]
		var button = SELECT_PRACTICE_BUTTON.instantiate()
		var data:Dictionary = {
			"boss_list": practice_difficulty.boss_list,
		}
		
		%DifficultyList.add_child(button)
		button.set_option_name(practice_difficulty.get_difficulty_name())
		button.set_option_data(data)
		button.data_return.connect(_on_DifficultyButton_pressed)
		
		if i == 0:
			FocusTargetDifficulty = button
		else:
			prev_button.focus_neighbor_bottom = prev_button.get_path_to(button)
			button.focus_neighbor_top = button.get_path_to(prev_button)
		prev_button = button


func validate_difficulties() -> void:
	valid_practice_difficulties = []
	
	for difficulty in practice_difficulties:
		if difficulty.flag_check():
			valid_practice_difficulties.append(difficulty)
		else:
			pass


func is_empty_difficulties() -> bool:
	return valid_practice_difficulties.size() == 0




func load_boss(index:int=-1) -> void:
	if index == -1:
		%BossName.text  = "None Avaliable"
		%Left.disabled  = true
		%Right.disabled = true
		FocusTargetBoss = FocusTargetDecoy
		
		for child in %SpellList.get_children():
			child.queue_free()
	
	else:
		var practice_boss = valid_practice_bosses[practice_boss_index]
		%BossName.text = practice_boss.get_boss_name()
		current_practice_boss_sprite      = practice_boss.boss_sprite_data
		current_practice_boss_music       = practice_boss.music_data
		current_practice_boss_background  = practice_boss.background_boss
		current_practice_stage_background = practice_boss.background_stage
		practice_spells                   = practice_boss.spell_list
		load_spells()


func set_index_boss(index:int=0) -> void:
	if is_empty_bosses():
		load_boss()
	
	else:
		practice_boss_index = index
		load_boss(practice_boss_index)


func change_index_boss(change:int) -> bool:
	if is_empty_bosses():
		load_boss()
		return false
	
	else:
		practice_boss_index = wrapi(
			practice_boss_index + change, 0, valid_practice_bosses.size()
		)
		
		load_boss(practice_boss_index)
		
		FocusTargetBoss.grab_focus()
		return true


func validate_bosses() -> void:
	valid_practice_bosses = []
	
	for boss in practice_bosses:
		if boss.flag_check():
			valid_practice_bosses.append(boss)
		else:
			pass


func is_empty_bosses() -> bool:
	return valid_practice_bosses.size() == 0




func load_spells() -> void:
	for child in %SpellList.get_children():
		child.queue_free()
	
	if practice_spells.size() == 0:
		FocusTargetBoss = %Decoy
	
	var prev_button:Control = %Title
	for i in practice_spells.size():
		var practice_spell = practice_spells[i]
		var button = SELECT_PRACTICE_BUTTON.instantiate()
		var data:Dictionary = {
			"spell": practice_spell,
		}
		
		%SpellList.add_child(button)
		button.set_option_name_numbered(practice_spell.get_boss_spell(), i + 1)
		button.set_option_data(data)
		button.data_return.connect(_on_SpellButton_pressed)
		
		if i == 0:
			FocusTargetBoss = button
		else:
			prev_button.focus_neighbor_bottom = prev_button.get_path_to(button)
			button.focus_neighbor_top = button.get_path_to(prev_button)
		prev_button = button




func _on_PlayerButton_pressed(button:Control) -> void:
	var data = button.get_option_data()
	current_practice_player = data["player"]
	current_practice_shot = data["shot"]
	
	FocusTargetPlayer = button
	
	load_in_difficulty()
	%Sound_Select02.play()


func _on_DifficultyButton_pressed(button:Control) -> void:
	var data = button.get_option_data()
	practice_bosses = data["boss_list"]
	
	FocusTargetDifficulty = button
	
	load_in_boss()
	%Sound_Select02.play()


func _on_SpellButton_pressed(button:Control) -> void:
	var data = button.get_option_data()
	current_practice_boss_spell = data["spell"]
	
	menu_active = false
	
	FocusTargetDecoy.grab_focus()
	
	selected.emit(
		current_practice_player, 
		current_practice_shot, 
		current_practice_stage_background,
		current_practice_boss_sprite,
		current_practice_boss_music,
		current_practice_boss_background,
		current_practice_boss_spell
	)
