extends Resource
class_name SaveFile
## A file for save data

@export var active:bool
@export var save_key:int

@export var section:int
@export var game_mode:int
@export var difficulty:int

@export var series:SeriesData
@export var series_index:int

@export var player:PlayerData
@export var shot:ShotData

@export var score:int
@export var power:int

@export var lives:int
@export var bombs:int
@export var continues:int

@export var lives_lost:int
@export var bombs_used:int
@export var spells_passed:int
@export var spells_captured:int

@export var start_player_lives:int
@export var start_player_bombs:int
@export var start_continues:int

@export var additional_start_lives:int
@export var additional_start_bombs:int




func set_save_file(
		section:int,
		game_mode:int,
		difficulty:int,
		player:PlayerData,
		shot:ShotData
	) -> void:
	
	self.section    = section
	self.game_mode  = game_mode
	self.difficulty = difficulty
	
	self.player     = player
	self.shot       = shot
	
	if section == GlobalSettings.SECTION.MAIN:
		self.series             = GlobalSettings.get_series_main()
		self.series_index       = 0
		self.score              = 0
		self.power              = 0
		self.spells_passed      = 0
		self.spells_captured    = 0
		self.start_player_lives = player.start_lives + GlobalSettings.get_additional_lives()
		self.start_player_bombs = player.start_bombs + GlobalSettings.get_additional_bombs()
		self.start_continues    = GlobalSettings.STARTING_CONTINUES_MAIN
		
		self.additional_start_lives = clampi(
			GlobalSettings.get_additional_lives(),
			0,
			7 - player.start_lives
		)
		
		self.additional_start_bombs = clampi(
			GlobalSettings.get_additional_lives(),
			0,
			7 - player.start_bombs
		)
	
	elif section == GlobalSettings.SECTION.EXTRA:
		self.series             = GlobalSettings.get_series_extra()
		self.series_index       = 0
		self.score              = 0
		self.power              = 0
		self.spells_passed      = 0
		self.spells_captured    = 0
		self.start_player_lives = player.start_lives + GlobalSettings.ADDITIONAL_LIVES_EXTRA
		self.start_player_bombs = player.start_bombs + GlobalSettings.ADDITIONAL_BOMBS_EXTRA
		self.start_continues    = GlobalSettings.STARTING_CONTINUES_EXTRA
		self.additional_start_lives = 0
		self.additional_start_bombs = 0
	
	elif section == GlobalSettings.SECTION.PHANTASM:
		self.series             = GlobalSettings.get_series_phantasm()
		self.series_index       = 0
		self.score              = 0
		self.power              = 0
		self.spells_passed      = 0
		self.spells_captured    = 0
		self.start_player_lives = player.start_lives + GlobalSettings.ADDITIONAL_LIVES_PHANTASM
		self.start_player_bombs = player.start_bombs + GlobalSettings.ADDITIONAL_BOMBS_PHANTASM
		self.start_continues    = GlobalSettings.STARTING_CONTINUES_PHANTASM
		self.additional_start_lives = 0
		self.additional_start_bombs = 0
	
	if section == GlobalSettings.SECTION.PRACTICE:
		self.score              = 0
		self.lives              = 0
		self.bombs              = 0
		self.power              = ceili(player.power_max * 0.6)
		self.continues          = 0
		self.spells_passed      = 0
		self.spells_captured    = 0
		self.start_player_lives = 0
		self.start_player_bombs = 0
		self.start_continues    = 0
		self.additional_start_lives = 0
		self.additional_start_bombs = 0
	
	self.lives     = start_player_lives
	self.bombs     = start_player_bombs
	self.continues = start_continues
	
	


func set_continue_game() -> void:
	if game_mode == GlobalSettings.MODE.CASUAL:
		set_reset_partial()
	
	elif game_mode == GlobalSettings.MODE.ARCADE:
		set_reset_full()


func set_reset_full() -> void:
	self.series_index    = 0
	self.score           = 0
	self.power           = 0
	self.lives_lost      = 0
	self.bombs_used      = 0
	self.spells_passed   = 0
	self.spells_captured = 0
	
	self.lives           = start_player_lives
	self.bombs           = start_player_bombs
	self.continues       = start_continues


func set_reset_partial() -> void:
	self.lives           = start_player_lives
	self.bombs           = start_player_bombs


func set_practice_series(practice_series:SeriesData) -> void:
	self.series       = practice_series
	self.series_index = 0


func save_full(data:Dictionary) -> void:
	self.score =           data["score"]
	self.lives =           data["lives"]
	self.bombs =           data["bombs"]
	self.power =           data["power"]
	self.lives_lost =      data["lives_lost"]
	self.bombs_used =      data["bombs_used"]
	self.spells_passed =   data["spells_passed"]
	self.spells_captured = data["spells_captured"]


func save_partial(data:Dictionary) -> void:
	self.lives_lost = data["lives_lost"]
	self.bombs_used = data["bombs_used"]


func save_next_stage() -> void:
	series_index += 1


func save_use_continue() -> void:
	self.continues -= 1


func save_deactivate() -> void:
	self.active = false


func is_complete() -> bool:
	return (series_index + 1) == series.stages.size()


func is_active() -> bool:
	return active




func get_player_data() -> PlayerData:
	return player


func get_player_object() -> Player:
	return player.create_player(shot)


func get_player_id() -> int:
	return player.id


func get_shot_id() -> int:
	return shot.id


func get_stage_data() -> StageData:
	return series.get_stage_data(series_index)


func get_stage_object() -> Stage:
	return series.get_stage_data(series_index).create_stage()


func get_stage_id() -> int:
	return series.get_stage_data(series_index).id


func get_record_character() -> String:
	return shot.get_shot_type()


func get_record_difficulty() -> String:
	return GlobalSettings.get_difficulty_string(difficulty)


func get_record_stage() -> String:
	return GlobalSettings.get_stage_string(GlobalStage.current_section, series_index)
