extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"

@export var players:Array[PlayerData]

var player_index:int = 0
var valid_players:Array[PlayerData] = []

var section:int

var menu_active:bool = false
var FocusTargetDecoy:Control

signal back
signal selected(character)




func _ready():
	toggle_buttons(false)
	place_text()
	
	FocusTargetDecoy = %Decoy


func _process(_delta:float) -> void:
	if ! Input.is_action_pressed("ui_left"):
		%Left.button_pressed = false
	if ! Input.is_action_pressed("ui_right"):
		%Right.button_pressed = false


func _input(event):
	if menu_active == false:
		return
	
	if event.is_action_pressed("menu_escape"):
		back.emit()
		%Sound_Select04.play()
	
	elif event.is_action_pressed("ui_left"):
		if ! change_index_player(-1): return
		%Left.button_pressed = true
		%Sound_Select02.play()
	
	elif event.is_action_pressed("ui_right"):
		if ! change_index_player(1): return
		%Right.button_pressed = true
		%Sound_Select02.play()
	
	elif event.is_action_pressed("menu_accept"):
		if is_empty_players(): return
		%Sound_Select02.play()
		selected.emit(valid_players[player_index])




func load_in(section:int) -> void:
	self.section = section
	
	validate_players()
	set_index_player()
	
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetDecoy.grab_focus()


func load_in_back() -> void:
	%Animator.play("Load_In_Back")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetDecoy.grab_focus()


func load_out() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out")


func load_out_next() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out_Next")




func toggle_buttons(enable:bool) -> void:
	menu_active = enable
	
	if enable == false:
		%Left.disabled = true
		%Right.disabled = true
	
	else:
		if valid_players.size() < 2:
			%Left.disabled = true
			%Right.disabled = true
		else:
			%Left.disabled = false
			%Right.disabled = false


func place_text() -> void:
	var text_dict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%Title.text = text_dict["player"]["title_01"]


func load_player(index:int=-1, target_portrait:Sprite2D=null) -> void:
	if target_portrait == null:
		%PlayerPortrait.position.x = 275
		%PlayerPortrait_Left.modulate.a = 1
		%PlayerPortrait_Right.modulate.a = 0
		target_portrait = %PlayerPortrait_Left
	
	if index == -1:
		%PlayerName.text =        "Not Avaliable"
		%PlayerTitle.text =       " "
		%PlayerDescription.text = " "
		%PlayerManual.text      = " "
	
	else:
		var player:PlayerData   = valid_players[index]
		%PlayerName.text        = player.get_player_name()
		%PlayerTitle.text       = player.get_player_title()
		%PlayerDescription.text = player.get_player_description(section).replace("\n", " ")
		%PlayerManual.text      = player.get_player_manual().replace("\n", " ")
		target_portrait.texture = player.selection_portrait


func set_index_player(index:int=0) -> void:
	if is_empty_players():
		load_player()
	
	else:
		load_player(index)


func change_index_player(turn:int) -> bool:
	if is_empty_players():
		load_player()
		return false
	
	if valid_players.size() == 1:
		return false
	
	else:
		var old_index = player_index
		var new_index = wrapi(
			player_index + turn, 0, valid_players.size()
		)
		player_index = new_index
		
		tween_players(old_index, new_index, turn)
		
		return true


func validate_players() -> void:
	player_index = 0
	valid_players = []
	
	for player in players:
		if player.flag_check(section):
			valid_players.append(player)
		else:
			pass


func is_empty_players() -> bool:
	return valid_players.size() == 0


func tween_players(old_index:int, new_index:int, turn:int) -> void:
	var SelectionTweener = create_tween().set_parallel(true)
	menu_active = false
	
	if turn == 1:
		load_player(old_index, %PlayerPortrait_Left)
		load_player(new_index, %PlayerPortrait_Right)
		%PlayerPortrait.position.x = 275
		%PlayerPortrait_Left.modulate.a = 1
		%PlayerPortrait_Right.modulate.a = 0
		SelectionTweener.tween_property(%PlayerPortrait, "position:x", -75, 0.3)
		SelectionTweener.tween_property(%PlayerPortrait_Left, "modulate:a", 0, 0.3)
		SelectionTweener.tween_property(%PlayerPortrait_Right, "modulate:a", 1, 0.3)
	elif turn == -1:
		load_player(old_index, %PlayerPortrait_Right)
		load_player(new_index, %PlayerPortrait_Left)
		%PlayerPortrait.position.x = -75
		%PlayerPortrait_Left.modulate.a = 0
		%PlayerPortrait_Right.modulate.a = 1
		SelectionTweener.tween_property(%PlayerPortrait, "position:x", 275, 0.3)
		SelectionTweener.tween_property(%PlayerPortrait_Left, "modulate:a", 1, 0.3)
		SelectionTweener.tween_property(%PlayerPortrait_Right, "modulate:a", 0, 0.3)
	else:
		load_player(new_index, %PlayerPortrait_Left)
		%PlayerPortrait.position.x = 275
		%PlayerPortrait_Left.modulate.a = 1
		%PlayerPortrait_Right.modulate.a = 0
		SelectionTweener.kill()
	await SelectionTweener.finished
	
	menu_active = true
