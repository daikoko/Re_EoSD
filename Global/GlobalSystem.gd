extends Node

## Global script for saving and storing information from user directory
## NOTE: Accessing variables from this script should use setters and getters
## NOTE: There are no setters

const USER_PATH := "user://"
const SAVE := "Save/"
const SAVE_FILE := "CurrentSave.res"
const SETTINGS_FILE := "CurrentSettings.res"
const RECORDS_MAIN := "Records_Main/"
const RECORDS_EXTRA := "Records_Extra/"
const RECORDS_PHANTASM := "Records_Phantasm/"
const MOD_PATH := "Mods/"

var CurrentSave:SaveFile
var CurrentSettings:SettingsFile
var RecordsMain:Array[RecordFile]
var RecordsExtra:Array[RecordFile]
var RecordsPhantasm:Array[RecordFile]




## Load all files from the user folder when starting game
func _ready():
	check_directory()
	load_mods()
	
	CurrentSave =     load_save_file()
	CurrentSettings = load_settings_file()
	RecordsMain =     load_records(GlobalSettings.SECTION.MAIN)
	RecordsExtra =    load_records(GlobalSettings.SECTION.EXTRA)
	RecordsPhantasm = load_records(GlobalSettings.SECTION.PHANTASM)




## -------------------------- ##
## ---- PUBLIC FUNCTIONS ---- ##
## -------------------------- ##


## Get the current save file
func get_current_save() -> SaveFile:
	return CurrentSave


## Get the current settings file
func get_current_settings() -> SettingsFile:
	return CurrentSettings


## Get the current record list for main section
func get_records_main() -> Array[RecordFile]:
	return RecordsMain


## Get the current record list for extra section
func get_records_extra() -> Array[RecordFile]:
	return RecordsExtra


func get_records_phantasm() -> Array[RecordFile]:
	return RecordsPhantasm


## Create and initialize a new save file
func create_save_file() -> SaveFile:
	var save = SaveFile.new()
	save.active = true
	save.save_key = int(create_date(true))
	return save


## Creates a record file from a save file
func create_record_file(save:SaveFile, player_name:String) -> RecordFile:
	var record = RecordFile.new()
	record.name =          player_name
	record.section =       save.section
	record.difficulty =    save.get_record_difficulty()
	record.character =     save.get_record_character()
	record.highest_stage = save.get_record_stage()
	record.score =         save.score
	record.date =          create_date(false)
	
	return record


## Save a save file
## Sets the current save file as this one
func save_save_file(Save:SaveFile) -> void:
	if Save.active:
		ResourceSaver.save(Save, USER_PATH + SAVE + SAVE_FILE)
		CurrentSave = Save
	else:
		ResourceSaver.save(Save, USER_PATH + SAVE + SAVE_FILE)
		CurrentSave = null


## Save a settings file
## Sets the current settings file as this one
func save_settings_file(Settings:SettingsFile) -> void:
	ResourceSaver.save(Settings, USER_PATH + SAVE + SETTINGS_FILE)
	CurrentSettings = Settings


## Save a record file to user directory
## Reload the record lists
func save_record_file(Record:RecordFile) -> void:
	var path = ""
	if Record.section == GlobalSettings.SECTION.MAIN:
		path = USER_PATH + RECORDS_MAIN
	elif Record.section == GlobalSettings.SECTION.EXTRA:
		path = USER_PATH + RECORDS_EXTRA
	elif Record.section == GlobalSettings.SECTION.PHANTASM:
		path = USER_PATH + RECORDS_PHANTASM
	
	ResourceSaver.save(Record, path + "Record_" + create_date(true) + ".res")
	RecordsMain =     load_records(GlobalSettings.SECTION.MAIN)
	RecordsExtra =    load_records(GlobalSettings.SECTION.EXTRA)
	RecordsPhantasm = load_records(GlobalSettings.SECTION.PHANTASM)


## Gets a JSON file as a dictionary from a file path
func get_json_dict(path:String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var data:Dictionary = JSON.parse_string(file.get_as_text())
	
	return data


## Conert integer to JSON key
func get_json_num_key(num:int) -> String:
	if num < 10:
		return "0" + str(num)
	else:
		return str(num)




## --------------------------- ##
## ---- PRIVATE FUNCTIONS ---- ##
## --------------------------- ##


## Create and initialize a settings file
func create_settings_file() -> SettingsFile:
	var Settings = SettingsFile.new()
	return Settings


## Load the save file from the user folder
## If no active save file exists, return a null
func load_save_file() -> SaveFile:
	var dir := DirAccess.open(USER_PATH)
	if dir.file_exists(USER_PATH + SAVE + SAVE_FILE):
		var Save:SaveFile = load(USER_PATH + SAVE + SAVE_FILE)
		if Save.active:
			return Save
		else:
			return null
	else:
		return null


## Load the settings file from the user folder.
## If no file exists, create and return a new file
func load_settings_file() -> SettingsFile:
	var dir := DirAccess.open(USER_PATH)
	if dir.file_exists(USER_PATH + SAVE + SETTINGS_FILE):
		return load(USER_PATH + SAVE + SETTINGS_FILE)
	else:
		return create_settings_file()


## Loads all record files from the user directory
## Organized by section type
func load_records(section:int) -> Array[RecordFile]:
	var records:Array[RecordFile] = []
	var dir:DirAccess
	var path:String
	if section == GlobalSettings.SECTION.MAIN:
		path = USER_PATH + RECORDS_MAIN
	elif section == GlobalSettings.SECTION.EXTRA:
		path = USER_PATH + RECORDS_EXTRA
	elif section == GlobalSettings.SECTION.PHANTASM:
		path = USER_PATH + RECORDS_PHANTASM
	
	dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			var record:RecordFile = load(path + file)
			var fit = false
			for i in records.size():
				var record_compare = records[i]
				if int(record.score) > int(record_compare.score):
					records.insert(i, record)
					fit = true
					break
			if fit == false:
				records.append(record)
	
	dir.list_dir_end()
	return records


## Check that neccesary directories exist
func check_directory() -> void:
	var dir := DirAccess.open(USER_PATH)
	if !dir.dir_exists(SAVE):
		dir.make_dir(SAVE)
	if !dir.dir_exists(RECORDS_MAIN):
		dir.make_dir(RECORDS_MAIN)
	if !dir.dir_exists(RECORDS_EXTRA):
		dir.make_dir(RECORDS_EXTRA)
	if !dir.dir_exists(RECORDS_PHANTASM):
		dir.make_dir(RECORDS_PHANTASM)


## Create a date string either for a file id or for user readability otherwise
func create_date(file:bool) -> String:
	var date:Dictionary = Time.get_datetime_dict_from_system()
	if file == false:
		return (
			str(date["month"]) + "/" + 
			str(date["day"]) + "/" + 
			str(date["year"])
			)
	else:
		return (
			str(date["year"]) + str(date["month"]) + str(date["day"]) + 
			str(date["hour"]) + str(date["minute"]) + str(date["second"])
			)


func load_mods() -> void:
	var path = OS.get_executable_path().get_base_dir() + "/" + MOD_PATH
	var dir = DirAccess.open(path)
	if dir == null:
		return
	
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".pck"):
			ProjectSettings.load_resource_pack(path + file)
	
	dir.list_dir_end()
