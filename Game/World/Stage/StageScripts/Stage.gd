extends Node2D
class_name Stage
## The stage scene

var stage_id:int
var stage_name:String
var stage_title:String
var stage_description:String

var StageBackground
var stage_music:MusicData
var stage_events:Animation

signal game_over
signal stage_finished




func _ready():
	GlobalStage.request_add_object.connect(_on_GlobalStage_request_add_object)
	GlobalStage.request_add_object_path.connect(_on_GlobalStage_request_add_object_path)
	GlobalStage.request_add_background.connect(_on_GlobalStage_request_add_background)
	GlobalStage.request_add_portrait.connect(_on_GlobalStage_request_add_portrait)
	GlobalStage.request_music_play.connect(_on_GlobalStage_request_music_play)
	GlobalStage.request_music_stop.connect(_on_GlobalStage_request_music_stop)
	GlobalStage.request_music_pause.connect(_on_GlobalStage_request_music_pause)
	GlobalStage.request_music_resume.connect(_on_GlobalStage_request_music_resume)
	GlobalStage.boss_end_phase.connect(_on_GlobalStage_boss_end_phase)
	GlobalPlayer.player_death.connect(_on_GlobalPlayer_player_death)
	GlobalPlayer.player_over.connect(_on_GlobalPlayer_player_over)
	GlobalPlayer.player_continued.connect(_on_GlobalPlayer_player_continued)
	GlobalPlayer.player_used_flash.connect(_on_GlobalPlayer_player_used_flash)
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_used_bomb)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalPlayer_player_used_bomb_stop)
	
	%Guide.hide()
	set_process(false)


func _process(_delta):
	GlobalStage.stage_progress_update.emit(
		%Animator.current_animation_position / %Animator.current_animation_length
	)
	
	# print(snappedf(%Animator.current_animation_position, 0.2))




func start() -> void:
	var id_sting = GlobalSystem.get_json_num_key(stage_id)
	
	var library = AnimationLibrary.new()
	library.add_animation(id_sting, stage_events)
	%Animator.add_animation_library("Library", library)
	%Animator.play("Library/" + id_sting)
	set_process(true)


func set_resources(background:PackedScene, music:MusicData, events:Animation) -> void:
	self.StageBackground = background.instantiate()
	add_background(StageBackground)
	
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		background_call("practice")
	
	self.stage_music = music
	self.stage_events = events




func play_intro() -> void:
	%Animator.pause()
	%StageEffects.play_intro(
		stage_name, 
		stage_title, 
		stage_description
	)
	await %StageEffects.intro_finished
	%Animator.play()


func event_spawn(event:EnemyData) -> void:
	# print(event.id)
	
	event.start()


func event_boss(event:BossData) -> void:
	%BossPlayer.start_boss(event)
	%Animator.pause()
	
	await GlobalStage.boss_end
	%Animator.play()


func background_call(method:String, args:Dictionary={}) -> void:
	StageBackground.background_call(method, args)


func music_play_stage() -> void:
	if (stage_id == 1) and (GlobalStage.current_player == GlobalSettings.PLAYER.RIN): 
		stage_music = load("res://Game/World/Stage/StageResources/Stage01/Audio/Music_03.tres")
	
	GlobalStage.request_music_play.emit(stage_music)


func music_play(data:MusicData) -> void:
	%StageEffects.play_music(data.get_music_name())
	%Music_Main.set_music(data)
	%Music_Main.play()


func music_stop() -> void:
	%Music_Main.stop()


func music_pause() ->void:
	%Music_Main.pause()


func music_resume() ->void:
	%Music_Main.resume()


func stage_bomb() -> void:
	GlobalStage.toggle_stage_bomb(true)
	%BombTimer.start()
	await %BombTimer.timeout
	
	GlobalStage.toggle_stage_bomb(false)


func stage_clear() -> void:
	GlobalStage.toggle_stage_clear(true)
	%ClearTimer.start()
	await %ClearTimer.timeout
	
	GlobalStage.toggle_stage_clear(false)


func add_background(object) -> void:
	%Backgrounds.add_child(object)




func _on_GlobalStage_request_add_object(object:Node):
	%StageObjects.add_child(object)


func _on_GlobalStage_request_add_object_path(object:Node, index:int):
	%Paths.get_child(index).add_child(object)


func _on_GlobalStage_request_add_background(object:Node):
	add_background(object)


func _on_GlobalStage_request_add_portrait(object:Node):
	%SpellPortraits.add_child(object)


func _on_GlobalStage_request_music_play(music:MusicData):
	music_play(music)


func _on_GlobalStage_request_music_stop():
	music_stop()


func _on_GlobalStage_request_music_pause():
	music_pause()


func _on_GlobalStage_request_music_resume():
	music_resume()


func _on_GlobalStage_boss_end_phase():
	stage_bomb()


func _on_GlobalPlayer_player_death():
	stage_clear()


func _on_GlobalPlayer_player_over():
	game_over.emit()


func _on_GlobalPlayer_player_continued():
	stage_clear()


func _on_GlobalPlayer_player_used_flash(spell_name:String):
	%StageEffects.play_flash_activated(spell_name)


func _on_GlobalPlayer_player_used_bomb(spell_name:String):
	%StageEffects.play_bomb_activated(spell_name)


func _on_GlobalPlayer_player_used_bomb_stop():
	%StageEffects.play_bomb_deactivated()


func _on_Animator_animation_finished(_anim_name):
	stage_finished.emit()
	
	GlobalStage.stage_progress_update.emit(1.0)
	await get_tree().process_frame
	set_process(false)
