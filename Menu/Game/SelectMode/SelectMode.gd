extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"

var menu_active:bool = false

var FocusTargetDefault:Control

signal back
signal selected(mode)




func _ready():
	toggle_buttons(false)
	place_text()
	
	FocusTargetDefault = %Casual


func _input(event):
	if menu_active == false:
		return
	
	if event.is_action_pressed("menu_escape"):
		back.emit()
		%Sound_Select04.play()




func start() -> void:
	toggle_buttons(true)
	FocusTargetDefault.grab_focus()


func load_in() -> void:
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	FocusTargetDefault = %Casual
	
	toggle_buttons(true)
	FocusTargetDefault.grab_focus()


func load_in_back() -> void:
	%Animator.play("Load_In_Back")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetDefault.grab_focus()


func load_out() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out")


func load_out_next() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out_Next")




func toggle_buttons(enable:bool) -> void:
	menu_active = enable


func place_text() -> void:
	var text_dict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%Title.text             = text_dict["mode"]["title_01"]
	%FreeName.text          = text_dict["mode"]["option_01"]
	%CasualName.text        = text_dict["mode"]["option_02"]
	%ArcadeName.text        = text_dict["mode"]["option_03"]
	%FreeDescription.text   = text_dict["mode"]["text_01"].replace("\n", " ")
	%CasualDescription.text = text_dict["mode"]["text_02"].replace("\n", " ")
	%ArcadeDescription.text = text_dict["mode"]["text_03"].replace("\n", " ")




func _on_Free_pressed() -> void:
	FocusTargetDefault = %Free
	
	selected.emit(GlobalSettings.MODE.FREE)
	%Sound_Select02.play()


func _on_Free_focus_entered() -> void:
	%FreeName.add_theme_color_override(
		"font_outline_color", 
		Color(1, 0, 0, 1)
	)


func _on_Free_focus_exited() -> void:
	%FreeName.add_theme_color_override(
		"font_outline_color", 
		Color(0, 0, 0, 1)
	)


func _on_Casual_pressed() -> void:
	FocusTargetDefault = %Casual
	
	selected.emit(GlobalSettings.MODE.CASUAL)
	%Sound_Select02.play()


func _on_Casual_focus_entered() -> void:
	%CasualName.add_theme_color_override(
		"font_outline_color", 
		Color(1, 0, 0, 1)
	)


func _on_Casual_focus_exited() -> void:
	%CasualName.add_theme_color_override(
		"font_outline_color", 
		Color(0, 0, 0, 1)
	)


func _on_Arcade_pressed() -> void:
	FocusTargetDefault = %Arcade
	
	selected.emit(GlobalSettings.MODE.ARCADE)
	%Sound_Select02.play()


func _on_Arcade_focus_entered() -> void:
	%ArcadeName.add_theme_color_override(
		"font_outline_color", 
		Color(1, 0, 0, 1)
	)


func _on_Arcade_focus_exited() -> void:
	%ArcadeName.add_theme_color_override(
		"font_outline_color", 
		Color(0, 0, 0, 1)
	)
