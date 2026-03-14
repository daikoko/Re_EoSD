extends Node2D

const ID := GlobalSettings.SHOT.REIMU_A
var spellname: String

const REIMU_SCREEN := preload("res://Game/Entities/Player/PlayerResources/Reimu/ShotA/Flash/ReimuScreen.tscn")

var avaliable:bool
var enabled:bool




func _ready():
	GlobalPlayer.updated_graze.connect(_on_GlobalPlayer_updated_graze)
	
	spellname = GlobalSettings.get_shot_text(ID, "flash")


func _input(event):
	if event.is_action_pressed("game_flash"):
		if enabled and avaliable:
			use_flash()




func toggle(enable:bool) -> void:
	self.enabled = enable


func use_flash() -> void:
	GlobalPlayer.player_used_flash.emit(spellname)
	
	var screen = REIMU_SCREEN.instantiate()
	screen.position = self.global_position
	GlobalStage.request_add_object.emit(screen)
	
	%Sound.play()




func _on_GlobalPlayer_updated_graze(avaliable):
	self.avaliable = avaliable
