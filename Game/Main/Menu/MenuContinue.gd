extends Control

const TEXT := "res://Game/_Text/GameText.json"
const TIME := 0.35
const SIZE_Y := 450.0

signal continued
signal restart
signal quit
signal exit




func _ready():
	place_text()


func hide_menu() -> void:
	self.visible = false
	toggle_buttons(false)
	%Animator.play("MenuOver_Out")


func show_menu(mode:int, continues:int) -> void:
	self.visible = true
	
	if mode == GlobalSettings.MODE.CASUAL:
		%MenuOver_Title.text = "Game Over"
		%ContinueBox.hide()
		
		%MenuOver_Restart.focus_neighbor_top    = %MenuOver_Restart.get_path_to(%MenuOver_Restart)
		%MenuOver_Restart.focus_neighbor_bottom = %MenuOver_Restart.get_path_to(%MenuOver_Exit)
		%MenuOver_Restart.focus_next            = %MenuOver_Restart.get_path_to(%MenuOver_Exit)
		%MenuOver_Restart.focus_previous        = %MenuOver_Restart.get_path_to(%MenuOver_Restart)
		
		%MenuOver_Exit.focus_neighbor_top       = %MenuOver_Exit.get_path_to(%MenuOver_Restart)
		%MenuOver_Exit.focus_neighbor_bottom    = %MenuOver_Exit.get_path_to(%MenuOver_Exit)
		%MenuOver_Exit.focus_next               = %MenuOver_Exit.get_path_to(%MenuOver_Exit)
		%MenuOver_Exit.focus_previous           =  %MenuOver_Exit.get_path_to(%MenuOver_Restart)
		
		%Animator.play("MenuOverCasual_In")
		await %Animator.animation_finished
		
		%MenuOver_Restart.grab_focus()
	
	elif mode == GlobalSettings.MODE.ARCADE:
		%MenuOver_Title.text = "Game Over"
		%ContinueBox.show()
		%MenuOver_ContinueCount.text = str(continues)
		
		%MenuOver_Continue.focus_neighbor_top    = %MenuOver_Continue.get_path_to(%MenuOver_Continue)
		%MenuOver_Continue.focus_neighbor_bottom = %MenuOver_Continue.get_path_to(%MenuOver_Quit)
		%MenuOver_Continue.focus_next            = %MenuOver_Continue.get_path_to(%MenuOver_Quit)
		%MenuOver_Continue.focus_previous        = %MenuOver_Continue.get_path_to(%MenuOver_Continue)
		
		%MenuOver_Quit.focus_neighbor_top        = %MenuOver_Quit.get_path_to(%MenuOver_Continue)
		%MenuOver_Quit.focus_neighbor_bottom     = %MenuOver_Quit.get_path_to(%MenuOver_Quit)
		%MenuOver_Quit.focus_next                = %MenuOver_Quit.get_path_to(%MenuOver_Quit)
		%MenuOver_Quit.focus_previous            = %MenuOver_Quit.get_path_to(%MenuOver_Continue)
		
		%Animator.play("MenuOverArcade_In")
		await %Animator.animation_finished
		
		%MenuOver_Continue.grab_focus()
	
	elif mode == GlobalSettings.MODE.PRACTICE:
		%MenuOver_Title.text = "Practice Over"
		%ContinueBox.hide()
		
		%MenuOver_Restart.focus_neighbor_top    = %MenuOver_Restart.get_path_to(%MenuOver_Restart)
		%MenuOver_Restart.focus_neighbor_bottom = %MenuOver_Restart.get_path_to(%MenuOver_Exit)
		%MenuOver_Restart.focus_next            = %MenuOver_Restart.get_path_to(%MenuOver_Exit)
		%MenuOver_Restart.focus_previous        = %MenuOver_Restart.get_path_to(%MenuOver_Restart)
		
		%MenuOver_Exit.focus_neighbor_top       = %MenuOver_Exit.get_path_to(%MenuOver_Restart)
		%MenuOver_Exit.focus_neighbor_bottom    = %MenuOver_Exit.get_path_to(%MenuOver_Exit)
		%MenuOver_Exit.focus_next               = %MenuOver_Exit.get_path_to(%MenuOver_Exit)
		%MenuOver_Exit.focus_previous           =  %MenuOver_Exit.get_path_to(%MenuOver_Restart)
		
		%Animator.play("MenuOverPractice_In")
		await %Animator.animation_finished
		
		%MenuOver_Restart.grab_focus()
	
	toggle_buttons(true)




func toggle_buttons(enable:bool) -> void:
	%MenuOver_Continue.disabled = !enable
	%MenuOver_Quit.disabled = !enable


func place_text() -> void:
	var text_dict = GlobalSystem.get_json_dict(TEXT)
	%MenuOver_Title.text =         text_dict["over"]["title_01"]
	%MenuOver_ContinueLabel.text = text_dict["over"]["label_01"]
	%MenuOver_Continue.text =      text_dict["over"]["option_01"]
	%MenuOver_Quit.text =          text_dict["over"]["option_02"]




func _on_MenuOver_Continue_pressed() -> void:
	continued.emit()
	hide_menu()
	%Sound_Select03.play()


func _on_MenuOver_restart_pressed() -> void:
	restart.emit()
	hide_menu()
	%Sound_Select03.play()


func _on_MenuOver_Quit_pressed() -> void:
	quit.emit()
	hide_menu()
	%Sound_Select04.play()


func _on_MenuOver_exit_pressed() -> void:
	exit.emit()
	hide_menu()
	%Sound_Select04.play()
