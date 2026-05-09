extends Node2D

const ID := GlobalSettings.SHOT.MARISA_A
var spellname: String

const BACKGROUND := preload("res://Game/Entities/Player/PlayerResources/_General/Bomb/SpellBackground_Player.tscn")
const GENERAL_BOMB := preload("res://Game/Entities/Player/PlayerResources/_General/Bomb/GeneralBomb.tscn")

const SPELL_PORTRAIT := preload("res://Game/Objects/Portrait/SpellPortrait.tscn")
const SPELL_PORTRAIT_DATA := preload("res://Game/Entities/Player/PlayerResources/Marisa/Sprite/SpellPortrait_PlayerMarisa.tres")

const SPEED := 2.0
const DAMAGE := 16000.0
const DURATION := 3.0

const ROTATION_SPEED := 90
const SHAKE_AMPLITUDE := 30
const SHAKE_DURATION := 0.8

var avaliable:bool
var enabled:bool

var PlayerBackground
var displacement:float = 0



func _ready():
	GlobalPlayer.updated_bomb.connect(_on_GlobalPlayer_updated_bomb)
	
	%Beam.visible = false
	%Beam.scale.x = 0
	%BeamBomb.disable()
	
	%Background.visible = false
	%Background.scale = Vector2.ZERO
	%BackgroundBomb.disable()
	
	%Particles.emitting = false
	
	spellname = GlobalSettings.get_shot_text(ID, "bomb")


func _process(delta):
	displacement += SPEED * delta
	%BeamBack.material.set_shader_parameter("displacement", displacement)
	%Background.rotation += deg_to_rad(ROTATION_SPEED * delta)


func _input(event):
	if event.is_action_pressed("game_bomb"):
		if enabled and avaliable and !GlobalStage.is_current_player_bomb():
			use_bomb()




func toggle(enable:bool) -> void:
	self.enabled = enable




func use_bomb():
	GlobalPlayer.player_used_bomb.emit(spellname)
	GlobalStage.player_bomb_activate()
	
	var SpellPortrait = SPELL_PORTRAIT.instantiate()
	SpellPortrait.set_portrait(SPELL_PORTRAIT_DATA)
	GlobalStage.request_add_portrait.emit(SpellPortrait)
	
	var bomb = GENERAL_BOMB.instantiate()
	bomb.position = global_position
	GlobalStage.request_add_object.emit(bomb)
	
	PlayerBackground = BACKGROUND.instantiate()
	GlobalStage.request_add_background.emit(PlayerBackground)
	
	%Animator.play("Bomb")
	%Sound.play()


func end_bomb():
	%BackgroundBomb.disable()
	
	GlobalPlayer.player_used_bomb_stop.emit()
	GlobalStage.player_bomb_deactivate()
	
	PlayerBackground.fixed_fade_out()


func request_shake():
	GlobalStage.request_shake.emit(SHAKE_AMPLITUDE, SHAKE_DURATION, true)


func request_shake_stop():
	GlobalStage.request_shake_release.emit()




func _on_GlobalPlayer_updated_bomb(avaliable):
	self.avaliable = avaliable


func _on_BeamBomb_collider_entered(collider, identity):
	if identity == "Enemy":
		collider.hit(DAMAGE)


func _on_IntervalTimer_timeout():
	%BeamBomb.enable()
	
	%FrameTimer.start()
	await %FrameTimer.timeout
	
	%BeamBomb.disable()
