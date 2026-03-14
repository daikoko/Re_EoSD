extends Node2D

const ID := GlobalSettings.SHOT.RIN_A
var spellname: String

const BACKGROUND := preload("res://Game/Entities/Player/PlayerResources/_General/Bomb/SpellBackground_Player.tscn")
const GENERAL_BOMB := preload("res://Game/Entities/Player/PlayerResources/_General/Bomb/GeneralBomb.tscn")
const RIN_WAVE := preload("res://Game/Entities/Player/PlayerResources/Rin/Bomb/RinWave.tscn")
const PETAL := preload("res://Game/Entities/Player/PlayerResources/Rin/Bomb/Bomb_Rin02.png")

const SPELL_PORTRAIT := preload("res://Game/Objects/Portrait/SpellPortrait.tscn")
const SPELL_PORTRAIT_DATA := preload("res://Game/Entities/Player/PlayerResources/Rin/Sprite/SpellPortrait_PlayerRin.tres")

const BACKGROUND_ROTATION := 120
const DECORATION_ROTATION := -180
const DAMAGE := 4000

var PlayerBackground
var avaliable:bool
var enabled:bool




func _ready() -> void:
	GlobalPlayer.updated_bomb.connect(_on_GlobalPlayer_updated_bomb)
	
	%BackgroundBomb.disable()
	%Background.scale = Vector2.ZERO
	%Decoration.scale = Vector2.ZERO
	%Decoration.modulate.a = 0
	
	spellname = GlobalSettings.get_shot_text(ID, "bomb")
	
	var angle = 0
	var angle_step = TAU / 12
	for _i in 12:
		var petal = Sprite2D.new()
		petal.texture = PETAL
		petal.offset.y = 100
		petal.rotation = angle
		
		%Decoration.add_child(petal)
		angle += angle_step


func _process(delta):
	%Background.rotation += deg_to_rad(BACKGROUND_ROTATION * delta)
	%Decoration.rotation += deg_to_rad(DECORATION_ROTATION * delta)


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
	
	%BackgroundBomb.enable()
	var bomb = GENERAL_BOMB.instantiate()
	bomb.position = global_position
	GlobalStage.request_add_object.emit(bomb)
	
	PlayerBackground = BACKGROUND.instantiate()
	GlobalStage.request_add_background.emit(PlayerBackground)
	
	%Animator.play("Bomb")
	%Sound.play()


func spawn_wave():
	var wave = RIN_WAVE.instantiate()
	wave.position = self.global_position
	wave.damage = DAMAGE
	GlobalStage.request_add_object.emit(wave)


func end_bomb():
	%BackgroundBomb.disable()
	
	GlobalPlayer.player_used_bomb_stop.emit()
	GlobalStage.player_bomb_deactivate()
	
	PlayerBackground.fixed_fade_out()



func _on_GlobalPlayer_updated_bomb(avaliable):
	self.avaliable = avaliable
