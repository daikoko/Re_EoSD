extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"

var title_active:bool = true

var FocusControlTitle:Button

signal loaded
signal selected_new_game
signal selected_continue
signal selected_extra
signal selected_practice
signal selected_records
signal selected_profiles
signal selected_musics
signal selected_manual
signal selected_settings
signal selected_quit




func _ready():
	place_text()
	toggle_buttons(false)
	
	FocusControlTitle = %NewGame


func _input(event):
	if event.is_action_pressed("menu_escape") and title_active:
		quit()




func load_in_start() -> void:
	%Animator.play("Load_In_Start")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusControlTitle.grab_focus()


func load_in() -> void:
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusControlTitle.grab_focus()
	loaded.emit()


func load_out() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out")




func toggle_buttons(enable:bool) -> void:
	%NewGame.disabled =   !enable
	%Practice.disabled =  !enable
	%Records.disabled =   !enable
	%Profiles.disabled =  true #!enable
	%MusicRoom.disabled = !enable
	%Settings.disabled =  !enable
	%Manual.disabled =    !enable
	%Quit.disabled =      !enable
	title_active = enable
	
	if enable and GlobalSystem.get_current_save() != null:
		%Continue.disabled = false
	else:
		%Continue.disabled = true
	
	if true: #enable and GlobalSettings.get_series_extra() != null:
		%Extra.disabled = false
	else:
		%Extra.disabled = true


func place_text() -> void:
	var TextDict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%SuperTitle.text = TextDict["title"]["title_01"]
	%MainTitle.text =  TextDict["title"]["title_02"]
	%SubTitle.text =   TextDict["title"]["title_03"]
	%NewGame.text =    TextDict["title"]["option_01"]
	%Continue.text =   TextDict["title"]["option_02"]
	%Extra.text =      TextDict["title"]["option_03"]
	%Practice.text =   TextDict["title"]["option_04"]
	%Records.text =    TextDict["title"]["option_05"]
	%Profiles.text =   TextDict["title"]["option_06"]
	%MusicRoom.text =  TextDict["title"]["option_07"]
	%Manual.text =     TextDict["title"]["option_08"]
	%Settings.text =   TextDict["title"]["option_09"]
	%Quit.text =       TextDict["title"]["option_10"]


func quit() -> void:
	toggle_buttons(false)
	selected_quit.emit()
	
	$Sound_Select04.play()



func _on_NewGame_pressed():
	toggle_buttons(false)
	selected_new_game.emit()
	
	FocusControlTitle = %NewGame
	$Sound_Select02.play()


func _on_Continue_pressed():
	toggle_buttons(false)
	selected_continue.emit()
	
	FocusControlTitle = %Continue


func _on_Extra_pressed():
	toggle_buttons(false)
	selected_extra.emit()
	
	FocusControlTitle = %Extra
	$Sound_Select02.play()


func _on_Practice_pressed():
	toggle_buttons(false)
	selected_practice.emit()
	
	FocusControlTitle = %Practice
	$Sound_Select02.play()


func _on_Records_pressed():
	toggle_buttons(false)
	selected_records.emit()
	
	FocusControlTitle = %Records
	$Sound_Select02.play()


func _on_Profiles_pressed():
	toggle_buttons(false)
	selected_profiles.emit()
	
	FocusControlTitle = %Profiles
	$Sound_Select02.play()


func _on_Musics_pressed():
	toggle_buttons(false)
	selected_musics.emit()
	
	FocusControlTitle = %MusicRoom
	$Sound_Select02.play()


func _on_Manual_pressed():
	toggle_buttons(false)
	selected_manual.emit()
	
	FocusControlTitle = %Manual
	$Sound_Select02.play()


func _on_Settings_pressed():
	toggle_buttons(false)
	selected_settings.emit()
	
	FocusControlTitle = %Settings
	$Sound_Select02.play()


func _on_Quit_pressed():
	quit()
