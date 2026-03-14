extends Control

const TEXT := "res://Game/_Text/GameText.json"
const TIME := 0.35
const SIZE_Y := 450.0

signal resume
signal restart
signal quit
signal exit




func _ready():
	place_text()


func hide_menu() -> void:
	self.visible = false
	toggle_buttons(false)
	%Animator.play("MenuPause_Out")


func show_menu(mode:int) -> void:
	self.visible = true
	
	if mode == GlobalSettings.MODE.CASUAL:
		
		%MenuPause_Resume.focus_neighbor_top     = %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		%MenuPause_Resume.focus_neighbor_bottom  =  %MenuPause_Resume.get_path_to(%MenuPause_Restart)
		%MenuPause_Resume.focus_next             = %MenuPause_Resume.get_path_to(%MenuPause_Restart)
		%MenuPause_Resume.focus_previous         =  %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		
		%MenuPause_Restart.focus_neighbor_top    = %MenuPause_Restart.get_path_to(%MenuPause_Resume)
		%MenuPause_Restart.focus_neighbor_bottom = %MenuPause_Restart.get_path_to(%MenuPause_Exit)
		%MenuPause_Restart.focus_next            = %MenuPause_Restart.get_path_to(%MenuPause_Exit)
		%MenuPause_Restart.focus_previous        = %MenuPause_Restart.get_path_to(%MenuPause_Resume)
		
		%MenuPause_Exit.focus_neighbor_top       = %MenuPause_Exit.get_path_to(%MenuPause_Restart)
		%MenuPause_Exit.focus_neighbor_bottom    = %MenuPause_Exit.get_path_to(%MenuPause_Exit)
		%MenuPause_Exit.focus_next               = %MenuPause_Exit.get_path_to(%MenuPause_Exit)
		%MenuPause_Exit.focus_previous           = %MenuPause_Exit.get_path_to(%MenuPause_Restart)
		
		%Animator.play("MenuPauseCasual_In")
		await %Animator.animation_finished
	
	elif mode == GlobalSettings.MODE.ARCADE:
		
		%MenuPause_Resume.focus_neighbor_top     = %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		%MenuPause_Resume.focus_neighbor_bottom  = %MenuPause_Resume.get_path_to(%MenuPause_Restart)
		%MenuPause_Resume.focus_next             = %MenuPause_Resume.get_path_to(%MenuPause_Restart)
		%MenuPause_Resume.focus_previous         = %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		
		%MenuPause_Restart.focus_neighbor_top    = %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		%MenuPause_Restart.focus_neighbor_bottom = %MenuPause_Resume.get_path_to(%MenuPause_Quit)
		%MenuPause_Restart.focus_next            = %MenuPause_Resume.get_path_to(%MenuPause_Quit)
		%MenuPause_Restart.focus_previous        = %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		
		%MenuPause_Quit.focus_neighbor_top       = %MenuPause_Quit.get_path_to(%MenuPause_Restart)
		%MenuPause_Quit.focus_neighbor_bottom    = %MenuPause_Quit.get_path_to(%MenuPause_Exit)
		%MenuPause_Quit.focus_next               = %MenuPause_Quit.get_path_to(%MenuPause_Exit)
		%MenuPause_Quit.focus_previous           = %MenuPause_Quit.get_path_to(%MenuPause_Restart)
		
		%MenuPause_Exit.focus_neighbor_top       = %MenuPause_Exit.get_path_to(%MenuPause_Quit)
		%MenuPause_Exit.focus_neighbor_bottom    = %MenuPause_Exit.get_path_to(%MenuPause_Exit)
		%MenuPause_Exit.focus_next               = %MenuPause_Exit.get_path_to(%MenuPause_Exit)
		%MenuPause_Exit.focus_previous           = %MenuPause_Exit.get_path_to(%MenuPause_Quit)
		
		%Animator.play("MenuPauseArcade_In")
		await %Animator.animation_finished
	
	elif mode == GlobalSettings.MODE.PRACTICE:
		
		%MenuPause_Resume.focus_neighbor_top     = %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		%MenuPause_Resume.focus_neighbor_bottom  =  %MenuPause_Resume.get_path_to(%MenuPause_Restart)
		%MenuPause_Resume.focus_next             = %MenuPause_Resume.get_path_to(%MenuPause_Restart)
		%MenuPause_Resume.focus_previous         =  %MenuPause_Resume.get_path_to(%MenuPause_Resume)
		
		%MenuPause_Restart.focus_neighbor_top    = %MenuPause_Restart.get_path_to(%MenuPause_Resume)
		%MenuPause_Restart.focus_neighbor_bottom = %MenuPause_Restart.get_path_to(%MenuPause_Exit)
		%MenuPause_Restart.focus_next            = %MenuPause_Restart.get_path_to(%MenuPause_Exit)
		%MenuPause_Restart.focus_previous        = %MenuPause_Restart.get_path_to(%MenuPause_Resume)
		
		%MenuPause_Exit.focus_neighbor_top       = %MenuPause_Exit.get_path_to(%MenuPause_Restart)
		%MenuPause_Exit.focus_neighbor_bottom    = %MenuPause_Exit.get_path_to(%MenuPause_Exit)
		%MenuPause_Exit.focus_next               = %MenuPause_Exit.get_path_to(%MenuPause_Exit)
		%MenuPause_Exit.focus_previous           = %MenuPause_Exit.get_path_to(%MenuPause_Restart)
		
		%Animator.play("MenuPausePractice_In")
		await %Animator.animation_finished
	
	toggle_buttons(true)
	%MenuPause_Resume.grab_focus()




func toggle_buttons(enable:bool) -> void:
	%MenuPause_Resume.disabled = !enable
	%MenuPause_Restart.disabled = !enable
	%MenuPause_Exit.disabled = !enable


func place_text() -> void:
	var text_dict = GlobalSystem.get_json_dict(TEXT)
	%MenuPause_Title.text =   text_dict["pause"]["title_01"]
	%MenuPause_Resume.text =  text_dict["pause"]["option_01"]
	%MenuPause_Restart.text = text_dict["pause"]["option_02"]
	%MenuPause_Exit.text =    text_dict["pause"]["option_03"]




func _on_MenuPause_Resume_pressed() -> void:
	resume.emit()
	hide_menu()
	%Sound_Select03.play()


func _on_MenuPause_Restart_pressed() -> void:
	restart.emit()
	hide_menu()
	%Sound_Select03.play()


func _on_MenuPause_quit_pressed() -> void:
	quit.emit()
	hide_menu()
	%Sound_Select04.play()


func _on_MenuPause_Exit_pressed() -> void:
	exit.emit()
	hide_menu()
	%Sound_Select04.play()
