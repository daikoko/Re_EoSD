extends Node2D

const ID := GlobalSettings.SHOT.RIN_B
var spellname: String

const DAMAGE := 4000
const ROTATION := 720

var avaliable:bool = false
var enabled:bool = false
var cooldown:bool = false




func _ready():
	GlobalPlayer.updated_graze.connect(_on_GlobalPlayer_updated_graze)
	spellname = GlobalSettings.get_shot_text(ID, "flash")
	
	%Bomb.disable()
	%Shield.scale = Vector2.ZERO


func _process(delta):
	%Shield.rotation += deg_to_rad(ROTATION) * delta


func _input(event):
	if event.is_action_pressed("game_flash"):
		if enabled and avaliable and !cooldown:
			use_flash()




func toggle(enable:bool) -> void:
	self.enabled = enable


func use_flash() -> void:
	GlobalPlayer.player_used_flash.emit(spellname)
	
	%Animator.play("Flash")
	
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


func _on_Bomb_collider_entered(other, other_identity):
	if other_identity == "Enemy":
		other.hit(DAMAGE)
