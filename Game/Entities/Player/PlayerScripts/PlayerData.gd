extends Resource
class_name PlayerData
## Contains data for a player

const PLAYER := preload("res://Game/Entities/Player/PlayerScripts/Player.tscn")
const PLAYER_COLLIDER := preload("res://Game/Entities/Player/PlayerScripts/PlayerCollider.tscn")
const SPRITE := preload("res://Game/Objects/Sprites/CustomSprite.tscn")

@export var id:GlobalSettings.PLAYER

@export_group("Sprite")
@export var selection_portrait:Texture2D
@export var sprite_frames:SpriteFrames
@export var sprite_offset:Vector2
@export var hitbox_inner:Texture2D
@export var hitbox_outer:Texture2D


@export_group("Respawn")
@export var respawn:DeathData
@export var power_loss:int

@export_group("Shots")
@export var bomb:PackedScene
@export var shots:Array[ShotData]

@export_group("Hitbox")
@export_range(1,10,1,"or_greater") var radius_hitbox:int = 1
@export_range(1,25,1,"or_greater") var radius_graze:int = 5
@export_range(1,75,1,"or_greater") var radius_collection:int = 25

@export_group("Speed")
@export_range(0,500,10, "or_greater") var speed_normal:float = 200
@export_range(0,500,10, "or_greater") var speed_focus:float = 140

@export_group("Power")
@export_range(1,1000,1,"or_greater") var power_max:int = 1000
@export_range(1,1000,1,"or_greater") var graze_max:int = 20
@export_range(1.0,2.0,0.1,"or_greater") var graze_scaling:float = 1.5

@export_group("Start")
@export_range(0,7) var start_lives:int = 2
@export_range(0,7) var start_bombs:int = 2

@export_group("Flag")
@export var flag_main:String
@export var flag_extra:String
@export var flag_phantasm:String
@export var flag_practice:String




func create_player(shot:ShotData) -> Player:
	var PlayerObject = PLAYER.instantiate()
	PlayerObject.speed_normal = speed_normal
	PlayerObject.speed_focus = speed_focus
	
	PlayerObject.set_sprite(
		SPRITE,
		sprite_frames,
		sprite_offset
	)
	PlayerObject.set_hitbox(
		PLAYER_COLLIDER,
		radius_hitbox, radius_graze, radius_collection, 
		hitbox_inner, hitbox_outer
	)
	PlayerObject.set_shot(
		respawn,
		bomb,
		shot
	)
	
	return PlayerObject


func flag_check(section:int) -> bool:
	if section == GlobalSettings.SECTION.MAIN:
		return GlobalSettings.flag_check(flag_main)
	elif section == GlobalSettings.SECTION.EXTRA:
		return GlobalSettings.flag_check(flag_extra)
	elif section == GlobalSettings.SECTION.PHANTASM:
		return GlobalSettings.flag_check(flag_phantasm)
	elif section == GlobalSettings.SECTION.PRACTICE:
		return GlobalSettings.flag_check(flag_practice)
	
	return false


func get_player_name() -> String:
	return GlobalSettings.get_player_text(id, "name")


func get_player_title() -> String:
	return GlobalSettings.get_player_text(id, "title")


func get_player_description(section:int) -> String:
	if section == GlobalSettings.SECTION.MAIN:
		return GlobalSettings.get_player_text(id, "description")
	elif section == GlobalSettings.SECTION.EXTRA:
		return GlobalSettings.get_player_text(id, "description_extra")
	elif section == GlobalSettings.SECTION.PHANTASM:
		return GlobalSettings.get_player_text(id, "description_phantasm")
	
	return ""


func get_shot_type(shot_index:int) -> String:
	return shots[shot_index].get_shot_type()


func get_shot_name(shot_index:int) -> String:
	return shots[shot_index].get_shot_name()


func get_shot_description(shot_index:int) -> String:
	return shots[shot_index].get_shot_description()
