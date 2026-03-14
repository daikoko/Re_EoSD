extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"
const SHOT_TYPE_BUTTON := preload("res://Menu/Game/SelectShot/SelectShotButton.tscn")

var menu_active:bool = false
var FocusTargetShot:BaseButton

signal back
signal selected(shot)




func _ready():
	toggle_buttons(false)
	place_text()


func _input(event):
	if menu_active == false:
		return
	
	if event.is_action_pressed("menu_escape"):
		back.emit()
		%Sound_Select04.play()




func load_in(character:PlayerData) -> void:
	load_shots(character)
	
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetShot.grab_focus()


func load_out() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out")


func load_out_next() -> void:
	toggle_buttons(false)




func toggle_buttons(enable:bool) -> void:
	menu_active = enable
	
	for button in %ShotList.get_children():
		button.disabled = !enable


func place_text() -> void:
	var text_dict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%Title.text = text_dict["shot"]["title_01"]


func load_shots(player:PlayerData) -> void:
	for button in %ShotList.get_children():
		button.queue_free()
	FocusTargetShot = %Decoy
	
	var prev_button:BaseButton = null
	for i in player.shots.size():
		var button = SHOT_TYPE_BUTTON.instantiate()
		var Shot:ShotData = player.shots[i]
		%ShotList.add_child(button)
		button.set_button(Shot)
		button.selected.connect(_on_ButtonShotType_selected)
		
		if i == 0:
			FocusTargetShot = button
		else:
			prev_button.focus_neighbor_bottom = prev_button.get_path_to(button)
			button.focus_neighbor_top = button.get_path_to(prev_button)
		prev_button = button




func _on_ButtonShotType_selected(Shot):
	selected.emit(Shot)
