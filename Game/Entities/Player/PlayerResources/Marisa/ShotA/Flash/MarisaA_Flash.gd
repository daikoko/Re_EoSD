extends Node2D

const ID := GlobalSettings.SHOT.MARISA_A
var spellname: String

const MARISA_STAR := preload("res://Game/Entities/Player/PlayerResources/Marisa/ShotA/Flash/MarisaStar.tscn")

const DAMAGE := 4000.0
const SPEED  := 800.0

var avaliable:bool
var enabled:bool

@onready var spawners := [
	%Marker01, 
	%Marker02, 
	%Marker03, 
	%Marker04, 
	%Marker05
]




func _ready():
	GlobalPlayer.updated_graze.connect(_on_GlobalPlayer_updated_charge)
	
	spellname = GlobalSettings.get_shot_text(ID, "flash")


func _input(event):
	if event.is_action_pressed("game_flash") and enabled and avaliable:
		use_flash()




func toggle(enable:bool) -> void:
	self.enabled = enable


func use_flash() -> void:
	GlobalPlayer.player_used_flash.emit(spellname)
	
	for spawner in spawners:
		var bullet = MARISA_STAR.instantiate()
		bullet.set_bullet(spawner.global_transform, DAMAGE, SPEED)
		GlobalStage.request_add_object.emit(bullet)
	
	%Sound.play()




func _on_GlobalPlayer_updated_charge(avaliable):
	self.avaliable = avaliable
