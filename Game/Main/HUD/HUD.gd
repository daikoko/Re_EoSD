extends CanvasLayer

const TEXT := "res://Game/_Text/HUDText.json"

var practice_mode:bool = false
var game_running:bool = false
var slow_effect_running:bool = false
var stop_effect_running:bool = false

var hiscore:int
var hiscore_true:int
var score:int
var score_true:int
var score_stage:int

var continues:int
var lives_lost:int
var bombs_used:int
var spells_passed:int
var spells_captured:int

var graze_scale:float
var power_loss:float
var start_lives:int
var start_bombs:int
var clear_bonus:int

var power_use_buffer:float

signal player_paused




func _ready():
	GlobalPlayer.player_hit.connect(_on_GlobalPlayer_player_hit)
	GlobalPlayer.player_graze.connect(_on_GlobalPlayer_player_graze)
	GlobalPlayer.life_get.connect(_on_GlobalPlayer_life_get)
	GlobalPlayer.bomb_get.connect(_on_GlobalPlayer_bomb_get)
	GlobalPlayer.point_get.connect(_on_GlobalPlayer_point_get)
	GlobalPlayer.power_get.connect(_on_GlobalPlayer_power_get)
	GlobalPlayer.score_get.connect(_on_GlobalPlayer_score_get)
	GlobalPlayer.bonus_spell_get.connect(_on_GlobalPlayer_bonus_spell_get)
	GlobalPlayer.bonus_graze_get.connect(_on_GlobalPlayer_bonus_graze_get)
	GlobalPlayer.bonus_clear_get.connect(_on_GlobalPlayer_bonus_clear_get)
	GlobalPlayer.spellcard_passed.connect(_on_GlobalPlayer_spellcard_passed)
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_used_bomb)
	GlobalPlayer.player_used_flash.connect(_on_GlobalPlayer_player_used_flash)
	GlobalPlayer.player_used_power.connect(_on_GlobalPlayer_player_used_power)
	GlobalPlayer.player_respawned.connect(_on_GlobalPlayer_player_respawned)
	GlobalPlayer.player_continued.connect(_on_GlobalPlayer_player_continued)
	GlobalPlayer.player_quit.connect(_on_GlobalPlayer_player_quit)
	GlobalStage.stage_progress_update.connect(_on_GlobalStage_stage_progress_update)
	GlobalStage.request_slow.connect(_on_GlobalStage_request_slow)
	GlobalStage.request_slow_release.connect(_on_GlobalStage_request_slow_release)
	GlobalStage.request_stop.connect(_on_GlobalStage_request_stop)
	GlobalStage.request_stop_release.connect(_on_GlobalStage_request_stop_release)
	place_text()


func _input(event):
	if event.is_action_pressed("game_escape"):
		
		if not game_running:    return
		if slow_effect_running: return
		if stop_effect_running: return
		
		player_paused.emit()




func set_hud(save:SaveFile) -> void:
	var player:PlayerData = save.get_player_data()
	var stage:StageData = save.get_stage_data()
	
	hiscore =      GlobalSettings.get_highscore(save.section)
	hiscore_true = hiscore
	score =        save.score
	score_true =   score
	score_stage =  0
	
	continues =       save.continues
	lives_lost =      save.lives_lost
	bombs_used =      save.bombs_used
	spells_passed =   save.spells_passed
	spells_captured = save.spells_captured
	
	graze_scale =  player.graze_scaling
	power_loss =   player.power_loss
	start_lives =  save.start_player_bombs
	start_bombs =  save.start_player_bombs
	clear_bonus =  stage.clear_bonus
	
	power_use_buffer = 0
	
	var difficulty = save.difficulty
	%DifficultyLabel.text =  GlobalSettings.get_difficulty_string(difficulty)
	%DifficultyLabel.add_theme_color_override(
		"font_outline_color",
		GlobalSettings.get_difficulty_color(difficulty)
	)
	%HiScore.text =     str(hiscore)
	%Score.text =       str(score)
	%Lives.value =      save.lives
	%Bombs.value =      save.bombs
	%Power.value =      10000 #save.power
	%Power.max_value =  10000 #player.power_max
	%Graze.value =      0
	%Graze.max_value =  player.graze_max
	
	%StageProgress.value = 0
	
	if save.game_mode == GlobalSettings.MODE.CASUAL:
		%CasualMode.show()
		match save.get_stage_id():
			1:
				%Power.value = player.power_max * 0
			2:
				%Power.value = player.power_max * 0.2
			3:
				%Power.value = player.power_max * 0.2
			4:
				%Power.value = player.power_max * 0.4
			5:
				%Power.value = player.power_max * 0.6
			6:
				%Power.value = player.power_max * 0.8
	elif save.game_mode == GlobalSettings.MODE.ARCADE:
		%ArcadeMode.show()
	
	if save.game_mode == GlobalSettings.MODE.PRACTICE:
		%PracticeMode.show()
	
	await get_tree().process_frame
	
	print(%Power.value)
	print(%Power.max_value)
	
	update_bomb()
	update_power()
	update_graze()


func place_text() -> void:
	var text_dict = GlobalSystem.get_json_dict(TEXT)
	
	%HiScoreLabel.text = text_dict["label_01"]
	%ScoreLabel.text =   text_dict["label_02"]
	%LivesLabel.text =   text_dict["label_03"]
	%BombsLabel.text =   text_dict["label_04"]
	%PowerLabel.text =   text_dict["label_05"]
	%GrazeLabel.text =   text_dict["label_06"]


func get_data() -> Dictionary:
	var data = {
		"highscore":       hiscore_true,
		"score":           score_true,
		"score_stage":     score_stage,
		"lives":           %Lives.value,
		"bombs":           %Bombs.value,
		"power":           %Power.value,
		"graze":           %Graze.value,
		"continues":       continues,
		"lives_lost":      lives_lost,
		"bombs_used":      bombs_used,
		"spells_passed":   spells_passed,
		"spells_captured": spells_captured,
		"clear_bonus":     clear_bonus
	}
	
	return data


func toggle_game_running(enable:bool = true) -> void:
	game_running = enable




func update_score(value:int=0) -> void:
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		return
	score += value
	%Score.text = str(score)
	if score > hiscore:
		hiscore = score
		%HiScore.text = str(hiscore)


func update_score_true(value:int=0) -> void:
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		return
	score_true += value
	score_stage += value
	if score_true > hiscore_true:
		hiscore_true = score_true


func update_lives(value:int=0) -> void:
	%Lives.value += value


func update_bomb(value:int=0) -> void:
	%Bombs.value += value
	if %Bombs.value > 0:
		GlobalPlayer.updated_bomb.emit(true)
	else:
		GlobalPlayer.updated_bomb.emit(false)


func update_power(value:int=0) -> void:
	%Power.value += value
	
	var percentage = %Power.value / float(%Power.max_value)
	%PowerDisplay.text = str(ceil(percentage * 100)) + "%"
	GlobalPlayer.updated_power.emit(percentage)


func update_graze(value:int=0) -> void:
	%Graze.value += value
	%GrazeDisplay.text = str(%Graze.value) + "/" + str(%Graze.max_value)
	if %Graze.value >= %Graze.max_value:
		GlobalPlayer.updated_graze.emit(true)
	else:
		GlobalPlayer.updated_graze.emit(false)


func bonus_get(value:int):
	update_score_true(value)
	
	var remainder = value % 240
	var interval = value / 240
	for i in 240:
		update_score(interval)
		await get_tree().process_frame
	
	update_score(remainder)


func play_animation() -> void:
	%Animator.play("Icon")




func _on_GlobalPlayer_player_hit():
	
	var grace_frames = 4
	for i in grace_frames:
		await get_tree().process_frame
		if (GlobalStage.is_current_player_bomb()): return
	
	Debug.add_hit()
	
	if Debug.debug_mode: return
	if not game_running: return
	
	update_power(-power_loss)
	
	%Sound_Death.play()
	if %Lives.value == 0:
		GlobalPlayer.player_over.emit()
	else:
		GlobalPlayer.player_death.emit()
		update_lives(-1)
		update_bomb(1)
		lives_lost += 1


func _on_GlobalPlayer_player_graze():
	Debug.add_graze()
	update_graze(1)
	update_power(1)
	%Sound_Graze.play()


func _on_GlobalPlayer_life_get():
	update_lives(1)
	%Sound_Item02.play()


func _on_GlobalPlayer_bomb_get():
	update_bomb(1)
	%Sound_Item02.play()


func _on_GlobalPlayer_point_get(value:int):
	# print("Point Get: ", value)
	update_score(value)
	update_score_true(value)
	%Sound_Item01.play()
	
	Debug.update_score_items(value)


func _on_GlobalPlayer_power_get(value:int):
	# print("Power Get: ", value)
	update_power(value)
	%Sound_Item01.play()


func _on_GlobalPlayer_score_get(value:int, mode:int = 0):
	update_score(value)
	update_score_true(value)
	
	if mode == 0:
		Debug.update_score_bullet(value)
	elif mode == 1:
		Debug.update_score_enemy(value)
	elif mode == 2:
		Debug.update_score_boss(value)


func _on_GlobalPlayer_bonus_spell_get(value:int):
	bonus_get(value)
	Debug.update_score_spell(value)


func _on_GlobalPlayer_bonus_graze_get(value:int):
	bonus_get(value)
	Debug.update_score_graze(value)


func _on_GlobalPlayer_bonus_clear_get(value:int):
	bonus_get(value)
	Debug.update_score_clear(value)


func _on_GlobalPlayer_spellcard_passed(captured:bool):
	spells_passed += 1
	if captured:
		spells_captured += 1


func _on_GlobalPlayer_player_used_bomb(_spellname:String):
	update_bomb(-1)
	bombs_used += 1


func _on_GlobalPlayer_player_used_flash(_spellname:String):
	var used_charge = %Graze.max_value
	%Graze.max_value = int(%Graze.max_value * graze_scale)
	update_graze(-used_charge)


func _on_GlobalPlayer_player_used_power(value:float):
	power_use_buffer += value
	
	if power_use_buffer > 1.0:
		var whole_power:int = floori(power_use_buffer)
		power_use_buffer -= whole_power
		update_power(-whole_power)


func _on_GlobalPlayer_player_respawned():
	pass


func _on_GlobalPlayer_player_continued():
	%Lives.value = start_lives
	%Bombs.value = start_bombs
	
	update_lives()
	update_bomb()


func _on_GlobalPlayer_player_quit():
	%Sound_Death.play()


func _on_GlobalStage_stage_progress_update(value):
	%StageProgress.value = value


func _on_GlobalStage_request_slow():
	slow_effect_running = true


func _on_GlobalStage_request_slow_release():
	slow_effect_running = false


func _on_GlobalStage_request_stop():
	stop_effect_running = true


func _on_GlobalStage_request_stop_release():
	stop_effect_running = false
