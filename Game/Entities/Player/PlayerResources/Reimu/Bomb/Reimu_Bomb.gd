extends Node2D

const ID := GlobalSettings.SHOT.REIMU_A
var spellname: String

const BACKGROUND := preload("res://Game/Entities/Player/PlayerResources/_General/Bomb/SpellBackground_Player.tscn")
const GENERAL_BOMB := preload("res://Game/Entities/Player/PlayerResources/_General/Bomb/GeneralBomb.tscn")
const REIMU_SEAL := preload("res://Game/Entities/Player/PlayerResources/Reimu/Bomb/ReimuSeal.tscn")

const SPELL_PORTRAIT := preload("res://Game/Objects/Portrait/SpellPortrait.tscn")
const SPELL_PORTRAIT_DATA := preload("res://Game/Entities/Player/PlayerResources/Reimu/Sprite/SpellPortrait_PlayerReimu.tres")

const SPAWNER_COUNT := 8
const DAMAGE := 1800.0
const SPEED := 600.0

const ROTATION_SPEED := -120

var avaliable:bool
var enabled:bool

var PlayerBackground
var spawners:Array = []




func _ready():
	GlobalPlayer.updated_bomb.connect(_on_GlobalPlayer_updated_bomb)
	
	var interval = TAU / SPAWNER_COUNT
	for i in SPAWNER_COUNT:
		var pos = Marker2D.new()
		pos.rotation = interval * i
		
		spawners.append(pos)
		self.add_child(pos)
	
	%Bomb.disable()
	%Main.scale = Vector2.ZERO
	
	spellname = GlobalSettings.get_shot_text(ID, "bomb")


func _process(delta):
	%Main.rotation += deg_to_rad(ROTATION_SPEED * delta)


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
	
	for spawner in spawners:
		var bullet = REIMU_SEAL.instantiate()
		bullet.set_bullet(spawner.global_transform, DAMAGE, SPEED, self)
		GlobalStage.request_add_object.emit(bullet)
	
	PlayerBackground = BACKGROUND.instantiate()
	GlobalStage.request_add_background.emit(PlayerBackground)
	
	$Animator.play("Bomb")
	%Bomb.enable()
	%Sound.play()


func end_bomb():
	%Bomb.disable()
	
	GlobalPlayer.player_used_bomb_stop.emit()
	GlobalStage.player_bomb_deactivate()
	
	PlayerBackground.fixed_fade_out()




func _on_GlobalPlayer_updated_bomb(avaliable):
	self.avaliable = avaliable
