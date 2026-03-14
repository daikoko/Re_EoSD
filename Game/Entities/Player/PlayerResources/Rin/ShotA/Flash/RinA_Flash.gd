extends Node2D

const ID := GlobalSettings.SHOT.RIN_A
var spellname: String

const RIN_STRING := preload("res://Game/Entities/Player/PlayerResources/Rin/ShotA/Flash/RinString.tscn")
const DAMAGE := 4000

var avaliable:bool = false
var enabled:bool = false
var cooldown:bool = false




func _ready():
	GlobalPlayer.updated_graze.connect(_on_GlobalPlayer_updated_graze)
	%Bomb.disable()
	
	spellname = GlobalSettings.get_shot_text(ID, "flash")


func _input(event):
	if event.is_action_pressed("game_flash"):
		if enabled and avaliable and !cooldown:
			use_flash()




func toggle(enable:bool) -> void:
	self.enabled = enable


func use_flash() -> void:
	GlobalPlayer.player_used_flash.emit(spellname)
	
	var screen = RIN_STRING.instantiate()
	screen.position = self.global_position
	screen.damage = DAMAGE
	GlobalStage.request_add_object.emit(screen)
	
	cooldown = true
	%Cooldown.start()
	
	%Bomb.enable()
	%Blocker.start()
	
	%Sound.play()




func _on_GlobalPlayer_updated_graze(avaliable):
	self.avaliable = avaliable


func _on_Cooldown_timeout():
	cooldown = false


func _on_Blocker_timeout():
	%Bomb.disable()
