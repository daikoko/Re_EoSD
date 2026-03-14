extends Resource
class_name StageData
## Contains data for a stage

const TEXT_FILE := "res://Game/World/_Text/StageText.json"
const STAGE := preload("res://Game/World/Stage/StageScripts/Stage.tscn")

@export var id:int

@export_group("Level")
@export var background:PackedScene
@export var music:MusicData
@export var events:Animation

@export_group("Bonus")
@export_range(0,10000,100,"or_greater") var clear_bonus:int

@export_group("Seed")
@export var level_seed:int = -1




func create_stage() -> Stage:
	var StageObject:Stage = STAGE.instantiate()
	StageObject.stage_id =          self.id
	StageObject.stage_name =        get_stage_name()
	StageObject.stage_title =       get_stage_title()
	StageObject.stage_description = get_stage_description()
	StageObject.set_resources(
		background,
		music,
		events
	)
	
	return StageObject




func get_stage_name() -> String:
	return GlobalSettings.get_stage_text(id, "name")


func get_stage_title() -> String:
	return GlobalSettings.get_stage_text(id, "title")


func get_stage_description() -> String:
	return GlobalSettings.get_stage_text(id, "description")


func get_clear_bonus() -> int:
	return clear_bonus
