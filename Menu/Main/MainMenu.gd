extends Node2D

signal selected_game(save, preserve)


func _ready():
	get_viewport().gui_focus_changed.connect(_on_Viewport_gui_focus_changed)
	
	self.position = Vector2.ZERO
	Debug.hide_debug()
	
	await get_tree().process_frame
	ready.emit()




func start_menu() -> void:
	%Title.load_in_start()
	%Music_Main.play()


func deactivate() -> void:
	%Game.deactivate()
	%Music_Main.stop()
	self.hide()


func reactivate() -> void:
	%Game.reactivate()
	%Music_Main.play()
	self.show()


func _on_Title_selected_new_game():
	%Title.load_out()
	%Game.load_in(%Game.MENU_MODE.NEW_GAME)



func _on_Title_selected_continue():
	%Game.load_in(%Game.MENU_MODE.CONTINUE)


func _on_Title_selected_extra():
	%Title.load_out()
	%Game.load_in(%Game.MENU_MODE.EXTRA)


func _on_Title_selected_practice():
	%Title.load_out()
	%Game.load_in(%Game.MENU_MODE.PRACTICE)


func _on_Title_selected_records():
	%Title.load_out()
	%Records.load_in()


func _on_Title_selected_profiles():
	pass


func _on_Title_selected_musics():
	%Title.load_out()
	%MusicRoom.load_in()
	await %MusicRoom.loaded
	
	%Music_Main.stop()


func _on_Title_selected_settings():
	%Title.load_out()
	%Settings.load_in()


func _on_Title_selected_manual():
	%Title.load_out()
	%Manual.load_in()


func _on_Title_selected_quit():
	get_tree().quit()


func _on_Game_back():
	%Game.load_out()
	%Title.load_in()


func _on_Game_selection_finished(save:SaveFile, preserve:bool=false):
	%Sound_Select03.play()
	selected_game.emit(save, preserve)


func _on_Records_back() -> void:
	%Records.load_out()
	%Title.load_in()


func _on_ProfileRoom_back():
	pass


func _on_MusicRoom_back():
	%MusicRoom.load_out()
	%Title.load_in()
	await %Title.loaded
	
	%Music_Main.play()


func _on_Settings_back():
	%Settings.load_out()
	%Title.load_in()


func _on_Manual_back():
	%Manual.load_out()
	%Title.load_in()


func _on_Viewport_gui_focus_changed(_node):
	%Sound_Select01.play()
