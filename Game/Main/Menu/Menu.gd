extends CanvasLayer

signal resume
signal restart
signal continued
signal exit
signal quit
signal next
signal finish



func _ready():
	get_viewport().gui_focus_changed.connect(_on_Viewport_gui_focus_changed)
	
	self.visible = true
	%MenuPause.hide_menu()
	%MenuOver.hide_menu()
	%MenuStage.hide_menu()
	%MenuGame.hide_menu()




func menu_pause(mode:int) -> void:
	%MenuPause.show_menu(mode)
	%Sound_Select02.play()


func menu_over(mode:int, continues:int=0) -> void:
	%MenuOver.show_menu(mode, continues)


func menu_stage(data:Dictionary) -> void:
	%MenuStage.show_menu(data)


func menu_game(save:SaveFile) -> void:
	%MenuGame.show_menu(save)


func menu_practice() -> void:
	menu_over(GlobalSettings.MODE.PRACTICE)




func _on_MenuPause_resume():
	%Blur.material.set_shader_parameter("lod", 0)
	resume.emit()


func _on_MenuPause_restart():
	%Blur.material.set_shader_parameter("lod", 0)
	restart.emit()


func _on_MenuPause_quit() -> void:
	quit.emit()


func _on_MenuPause_exit():
	exit.emit()


func _on_MenuOver_continued():
	continued.emit()


func _on_MenuOver_restart() -> void:
	restart.emit()


func _on_MenuOver_quit():
	quit.emit()


func _on_MenuOver_exit() -> void:
	exit.emit()


func _on_MenuStage_next():
	next.emit()


func _on_MenuGame_finish():
	finish.emit()


func _on_MenuPractice_restart():
	restart.emit()


func _on_MenuPractice_exit():
	exit.emit()


func _on_Viewport_gui_focus_changed(_node):
	%Sound_Select01.play()
