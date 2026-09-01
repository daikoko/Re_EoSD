extends Node

## Global script the current settings
## NOTE: Accessing variables from this script should use setters and getters
## NOTE: There are no setters

## JSON files
const SECTION_TEXT := "res://Menu/_Text/SectionText.json"
const MUSIC_TEXT :=   "res://Menu/Musics/_Text/MusicText.json"
const PLAYER_TEXT :=  "res://Game/Entities/_Text/PlayerText.json"
const SHOT_TEXT :=    "res://Game/Entities/_Text/ShotText.json"
const BOSS_TEXT :=    "res://Game/Entities/_Text/BossText.json"
const STAGE_TEXT :=   "res://Game/World/_Text/StageText.json"

## Enumeration for sections
enum SECTION {
	MAIN,
	EXTRA,
	PHANTASM,
	PRACTICE
}

## Enumeration for game mode
enum MODE {
	FREE,
	CASUAL,
	ARCADE,
	PRACTICE
}

## Enumeration for difficulty
enum DIFFICULTY {
	EASY,
	NORMAL,
	HARD,
	LUNATIC,
	EXTRA,
	PHANTASM,
	PRACTICE
}

## Enumeration for players
enum PLAYER {
	TEST,
	REIMU,
	MARISA,
	RIN
}

## Enumeration for shots
enum SHOT {
	TEST,
	REIMU_A,
	REIMU_B,
	MARISA_A,
	MARISA_B,
	RIN_A,
	RIN_B
}

## Enumeration for bosses
enum BOSS {
	TEST,
	RUMIA,
	DAIYOUSEI,
	CIRNO,
	MEILING,
	KOAKUMA,
	PATCHOULI,
	SAKUYA,
	REMILIA,
	FLANDRE
}

## Starting amount of continues
const STARTING_CONTINUES_MAIN     := 100
const STARTING_CONTINUES_EXTRA    := 0
const STARTING_CONTINUES_PHANTASM := 0

const ADDITIONAL_LIVES_EXTRA      := 2
const ADDITIONAL_BOMBS_EXTRA      := 1

const ADDITIONAL_LIVES_PHANTASM   := 4
const ADDITIONAL_BOMBS_PHANTASM   := 2

const ADDITIONAL_LIVES_PENALTY    := -0.05
const ADDITIONAL_BOMBS_PENALTY    := -0.05

## Set by current settings file
var highscore:int
var highscore_extra:int
var highscore_phantasm:int
var last_record:String

var additional_lives:int
var additional_bombs:int
var volume_sound:float
var volume_music:float
var Flags:Dictionary

## Set at a later time
var SeriesMain #:SeriesData
var SeriesExtra #:SeriesData
var SeriesPhantasm #:SeriesData

var SectionText:Dictionary
var PlayerText:Dictionary
var ShotText:Dictionary
var BossText:Dictionary
var StageText:Dictionary
var MusicText:Dictionary

signal settings_changed




## Initialize setting file members
func _ready():
	SectionText = GlobalSystem.get_json_dict(SECTION_TEXT)
	PlayerText = GlobalSystem.get_json_dict(PLAYER_TEXT)
	ShotText = GlobalSystem.get_json_dict(SHOT_TEXT)
	BossText = GlobalSystem.get_json_dict(BOSS_TEXT)
	StageText = GlobalSystem.get_json_dict(STAGE_TEXT)
	MusicText = GlobalSystem.get_json_dict(MUSIC_TEXT)
	update_from_file()




## -------------------------- ##
## ---- PUBLIC FUNCTIONS ---- ##
## -------------------------- ##


## Get adjustable settings as a dict
func get_settings() -> Dictionary:
	var settings_dict = {
		"additional_lives": self.additional_lives,
		"additional_bombs": self.additional_bombs,
		"volume_sound":     self.volume_sound,
		"volume_music":     self.volume_music,
	}
	
	return settings_dict


func get_additional_lives() -> float:
	return additional_lives


func get_additional_bombs() -> float:
	return additional_bombs


func get_volume_music() -> float:
	return volume_music


func get_volume_sound() -> float:
	return volume_sound


## Update adjustable settings
func update_settings(SettingsDict:Dictionary) -> void:
	self.additional_lives = SettingsDict["additional_lives"]
	self.additional_bombs = SettingsDict["additional_bombs"]
	self.volume_sound =     SettingsDict["volume_sound"]
	self.volume_music =     SettingsDict["volume_music"]
	
	settings_changed.emit()
	
	update_file()


## Get highscore
func get_highscore(section:int) -> int:
	if section == SECTION.MAIN:
		return highscore
	elif section == SECTION.EXTRA:
		return highscore_extra
	elif section == SECTION.PHANTASM:
		return highscore_phantasm
	else:
		return 0


## Update highscore
func update_highscore(section:int, highscore:int) -> void:
	if section == SECTION.MAIN:
		self.highscore = highscore
	elif section == SECTION.EXTRA:
		self.highscore_extra = highscore
	elif section == SECTION.PHANTASM:
		self.highscore_phantasm = highscore
	
	update_file()


func get_last_record() -> String:
	return last_record


func update_last_record(last_record:String) -> void:
	self.last_record = last_record
	
	update_file()


## Set the series
func set_series(SeriesMain:SeriesData, SeriesExtra:SeriesData, SeriesPhantasm:SeriesData) -> void:
	self.SeriesMain     =  SeriesMain
	self.SeriesExtra    = SeriesExtra
	self.SeriesPhantasm = SeriesPhantasm


## Get the series by section
func get_series_main() -> SeriesData:
	return SeriesMain


func get_series_extra() -> SeriesData:
	if flag_check("Passed_MainSeries"): return SeriesExtra
	else:                               return null


func get_series_phantasm() -> SeriesData:
	if flag_check("Passed_MainSeries"): return SeriesPhantasm
	else:                               return null


## Get difficulty as string from section and difficulty
func get_difficulty_string(difficulty:int) -> String:
	match difficulty:
		DIFFICULTY.EASY:
			return SectionText["difficulty"]["easy"]
		DIFFICULTY.NORMAL:
			return SectionText["difficulty"]["normal"]
		DIFFICULTY.HARD:
			return SectionText["difficulty"]["hard"]
		DIFFICULTY.LUNATIC:
			return SectionText["difficulty"]["lunatic"]
		DIFFICULTY.EXTRA:
			return SectionText["difficulty"]["extra"]
		DIFFICULTY.PHANTASM:
			return SectionText["difficulty"]["phantasm"]
		DIFFICULTY.PRACTICE:
			return SectionText["difficulty"]["practice"]
	
	return ""


func get_difficulty_color(difficulty:int) -> Color:
	match difficulty:
		DIFFICULTY.EASY:
			return Color(0,   0.8, 1.0)
		DIFFICULTY.NORMAL:
			return Color(0,   0.8, 0)
		DIFFICULTY.HARD:
			return Color(0.8, 0.8, 0)
		DIFFICULTY.LUNATIC:
			return Color(0.8, 0,   0)
		DIFFICULTY.EXTRA:
			return Color(0.8, 0,   0)
		DIFFICULTY.PHANTASM:
			return Color(0.8, 0,   0.8)
		DIFFICULTY.PRACTICE:
			return Color(0,   0,   0)
	
	return Color(0, 0, 0)


func get_difficulty_key_string(difficulty:int) -> String:
	match difficulty:
		DIFFICULTY.EASY:
			return "Easy"
		DIFFICULTY.NORMAL:
			return "Normal"
		DIFFICULTY.HARD:
			return "Hard"
		DIFFICULTY.LUNATIC:
			return "Lunatic"
		DIFFICULTY.EXTRA:
			return "Normal"
		DIFFICULTY.PHANTASM:
			return "Normal"
		DIFFICULTY.PRACTICE:
			return "Normal"
	
	return ""


func get_stage_string(section:int, series_index:int) -> String:
	if section == GlobalSettings.SECTION.MAIN:
		return SectionText["stage"]["stage"] + " " + str(series_index + 1)
	elif section == GlobalSettings.SECTION.EXTRA:
		return SectionText["stage"]["extra"]
	elif section == GlobalSettings.SECTION.PHANTASM:
		return SectionText["stage"]["phantasm"]
	
	return ""


func get_player_text(player_id:int, text:String) -> String:
	return PlayerText[GlobalSystem.get_json_num_key(player_id)][text]


func get_shot_text(shot_id:int, text:String) -> String:
	return ShotText[GlobalSystem.get_json_num_key(shot_id)][text]


func get_boss_text(boss_id:int, text:String) -> String:
	return BossText[GlobalSystem.get_json_num_key(boss_id)][text]


func get_stage_text(level_id:int, text:String) -> String:
	return StageText[GlobalSystem.get_json_num_key(level_id)][text]


func get_music_text(music_id:int) -> String:
	return MusicText[GlobalSystem.get_json_num_key(music_id)]





func flag_check(flag:String) -> bool:
	if Debug.debug_mode:
		return true
	
	if flag == "":
		return true
	elif !Flags.has(flag):
		return false
	else:
		return Flags[flag]


func flag_change(flag:String, value:bool) -> void:
	Flags[flag] = value
	
	update_file()




## --------------------------- ##
## ---- PRIVATE FUNCTIONS ---- ##
## --------------------------- ##


## Update settings from the settings file
func update_from_file() -> void:
	var settings:SettingsFile = GlobalSystem.get_current_settings()
	
	self.last_record        = settings.last_record
	self.highscore          = settings.highscore
	self.highscore_extra    = settings.highscore_extra
	self.highscore_phantasm = settings.highscore_phantasm
	self.additional_lives   = settings.additional_lives
	self.additional_bombs   = settings.additional_bombs
	self.volume_sound       = settings.volume_sound
	self.volume_music       = settings.volume_music
	self.Flags              = settings.Flags


## Update the settings file
func update_file() -> void:
	var settings:SettingsFile = GlobalSystem.get_current_settings()
	
	settings.last_record        = self.last_record
	settings.highscore          = self.highscore
	settings.highscore_extra    = self.highscore_extra
	settings.highscore_phantasm = self.highscore_phantasm
	settings.additional_lives   = self.additional_lives
	settings.additional_bombs   = self.additional_bombs
	settings.volume_sound       = self.volume_sound
	settings.volume_music       = self.volume_music
	settings.Flags              = self.Flags
	
	GlobalSystem.save_settings_file(settings)
