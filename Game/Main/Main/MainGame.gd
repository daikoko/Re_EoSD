extends Node2D

var save:SaveFile

var CurrentStage:Stage
var CurrentPlayer:Player

signal exited_game




func _ready():
	Debug.show_debug()
	
	%HUD.set_hud(save)
	%Pool.set_pools()
	
	await get_tree().process_frame
	ready.emit()




func start_game() -> void:
	GlobalStage.current_section =    save.section
	GlobalStage.current_difficulty = save.difficulty
	GlobalStage.current_player =     save.get_player_id()
	GlobalStage.current_shot =       save.get_shot_id()
	
	GlobalStage.toggle_stage_clear_plain(true)
	
	%HUD.play_animation()
	set_stage()




func pause(pause_music:bool) -> void:
	%HUD.toggle_game_running(false)
	%MainGameWorld.pause(pause_music)


func resume() -> void:
	%HUD.toggle_game_running(true)
	%MainGameWorld.resume()


func set_stage() -> void:
	CurrentPlayer = save.get_player_object()
	CurrentPlayer.position = GlobalStage.PLAYER_DEFAULT_POSITION
	
	CurrentStage = save.get_stage_object()
	CurrentStage.game_over.connect(_on_Stage_game_over)
	CurrentStage.stage_finished.connect(_on_Stage_stage_finished)
	GlobalStage.reset_states()
	
	%GameCamera.offset = GlobalStage.VIEWPORT_SIZE / 2
	%GameWindow.add_child(CurrentStage)
	%GameWindow.add_child(CurrentPlayer)
	%HUD.set_hud(save)
	Debug.reset_debug()
	
	%MainGameCover.stage_cover_out()
	await %MainGameCover.stage_out
	
	CurrentStage.start()
	CurrentPlayer.start()
	%HUD.toggle_game_running(true)
	
	GlobalStage.toggle_stage_clear_plain(false)


func stop_stage() -> void:
	GlobalStage.toggle_stage_clear_plain(true)
	GlobalStage.stage_progress_update.emit(0)
	
	CurrentStage.queue_free()
	CurrentPlayer.queue_free()


func reset_stage() -> void:
	GlobalStage.stage_reset.emit()
	
	if save.game_mode == GlobalSettings.MODE.CASUAL:
		save.set_reset_partial()
	
	%MainGameCover.stage_cover_in()
	await %MainGameCover.stage_in
	
	stop_stage()
	var StageTimer = GlobalStage.create_timer(self, 0.5)
	StageTimer.start()
	await StageTimer.timeout
	
	set_stage()
	StageTimer.queue_free()


func reset_game() -> void:
	GlobalStage.stage_reset.emit()
	
	save.set_reset_full()
	
	%MainGameCover.stage_cover_in()
	await %MainGameCover.stage_in
	
	stop_stage()
	var StageTimer = GlobalStage.create_timer(self, 0.5)
	StageTimer.start()
	await StageTimer.timeout
	
	set_stage()
	StageTimer.queue_free()


func next_stage() -> void:
	save_game_full()
	
	if save.is_complete():
		%Menu.menu_game(save)
	else:
		save.save_next_stage()
		reset_stage()


func game_continued() -> void:
	save_game_partial()
	save.save_use_continue()
	
	resume()
	GlobalPlayer.player_continued.emit()


func game_quit() -> void:
	game_over()
	GlobalPlayer.player_quit.emit()


func game_over() -> void:
	pause(true)
	
	save_game_full()
	save.save_deactivate()
	
	Debug.hide_debug()
	
	%Record.start(save)
	%Record.play_music()
	await %Record.record_finish
	
	exit()


func game_finish() -> void:
	save_game_full()
	save.save_deactivate()
	
	if GlobalStage.current_section == GlobalSettings.SECTION.MAIN:
		GlobalSettings.flag_change("Passed_MainSeries", true)
		match GlobalStage.current_player:
			GlobalSettings.PLAYER.REIMU:
				GlobalSettings.flag_change("Passed_MainSeries_Reimu", true)
			GlobalSettings.PLAYER.MARISA:
				GlobalSettings.flag_change("Passed_MainSeries_Marisa", true)
			GlobalSettings.PLAYER.RIN:
				GlobalSettings.flag_change("Passed_MainSeries_Rin", true)
	if GlobalStage.current_section == GlobalSettings.SECTION.EXTRA:
		GlobalSettings.flag_change("Passed_ExtraSeries", true)
		match GlobalStage.current_player:
			GlobalSettings.PLAYER.REIMU:
				GlobalSettings.flag_change("Passed_ExtraSeries_Reimu", true)
			GlobalSettings.PLAYER.MARISA:
				GlobalSettings.flag_change("Passed_ExtraSeries_Marisa", true)
			GlobalSettings.PLAYER.RIN:
				GlobalSettings.flag_change("Passed_ExtraSeries_Rin", true)
	if GlobalStage.current_section == GlobalSettings.SECTION.PHANTASM:
		GlobalSettings.flag_change("Passed_PhantasmSeries", true)
	
	Debug.hide_debug()
	Debug.hide_all()
	
	pause(false)
	if save.game_mode == GlobalSettings.MODE.CASUAL:
		%EndingPlayer.start(save)
		await %EndingPlayer.ending_finished
		
		%Credits.start()
		await %Credits.credits_finished
		
		Debug.show_all()
		exit()
	
	elif save.game_mode == GlobalSettings.MODE.ARCADE:
		%Record.start(save)
		await %Record.record_finish
		
		%EndingPlayer.start(save)
		await %EndingPlayer.ending_finished
		
		%Credits.start()
		await %Credits.credits_finished
		
		Debug.show_all()
		exit()


func exit() -> void:
	Debug.hide_debug()
	
	exited_game.emit()


func save_game_full() -> void:
	save.save_full(%HUD.get_data())
	
	if save.score > GlobalSettings.get_highscore(save.section):
		GlobalSettings.update_highscore(save.section, save.score)
	
	if GlobalStage.current_section == GlobalSettings.SECTION.MAIN:
		GlobalSystem.save_save_file(save)


func save_game_partial()-> void:
	save.save_partial(%HUD.get_data())
	
	if GlobalStage.current_section == GlobalSettings.SECTION.MAIN:
		GlobalSystem.save_save_file(save)




func _on_Stage_game_over():
	%HUD.toggle_game_running(false)
	
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		var delay = GlobalStage.create_timer(self, 1.0)
		delay.start()
		await delay.timeout
		
		delay.queue_free()
		pause(true)
		%Menu.menu_practice()
		return
	
	if save.continues != 0:
		var delay = GlobalStage.create_timer(self, 1.0)
		delay.start()
		await delay.timeout
		
		delay.queue_free()
		pause(true)
		%Menu.menu_over(save.game_mode, save.continues)
	
	else:
		game_over()


func _on_Stage_stage_finished():
	%HUD.toggle_game_running(false)
	
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		pause(true)
		%Menu.menu_practice()
	
	else:
		%Menu.menu_stage(%HUD.get_data())
		
		match save.get_stage_id():
			1:
				GlobalSettings.flag_change("Passed_Stage1", true)
			2:
				GlobalSettings.flag_change("Passed_Stage2", true)
			3:
				GlobalSettings.flag_change("Passed_Stage3", true)
			4:
				GlobalSettings.flag_change("Passed_Stage4", true)
			5:
				GlobalSettings.flag_change("Passed_Stage5", true)
			6:
				GlobalSettings.flag_change("Passed_Stage6", true)
			7:
				GlobalSettings.flag_change("Passed_StageExtra", true)
			8:
				GlobalSettings.flag_change("Passed_StagePhantasm", true)
	
	CurrentPlayer.toggle_shot(false)


func _on_HUD_player_paused() -> void:
	pause(true)
	%Menu.menu_pause(save.game_mode)


func _on_Menu_resume() -> void:
	resume()


func _on_Menu_restart() -> void:
	resume()
	
	if save.game_mode == GlobalSettings.MODE.CASUAL:
		reset_stage()
	elif save.game_mode == GlobalSettings.MODE.ARCADE:
		reset_game()
	elif save.game_mode == GlobalSettings.MODE.PRACTICE:
		reset_stage()


func _on_Menu_exit() -> void:
	exit()


func _on_Menu_continued() -> void:
	game_continued()


func _on_Menu_quit() -> void:
	game_quit()


func _on_Menu_next() -> void:
	await get_tree().process_frame
	
	next_stage()


func _on_Menu_finish() -> void:
	game_finish()
