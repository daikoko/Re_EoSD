extends Node2D
class_name BossObject

enum ANIMATION_STATE {
	DEFAULT,
	CUSTOM,
	TRANSITION
}

var Sprite:CustomSprite_Boss
var ChargeParticles:GPUParticles2D
var immunity:bool = true

var animation_state:int = ANIMATION_STATE.DEFAULT
var back_animation:String
var current_animation:String
var current_key:int

var bomb_immunity:bool = false
var invincibility:bool = false

var MoveTween:Tween
var Waiters:Node2D

var active:bool

signal animation_finished
signal movement_finished



func _ready():
	GlobalStage.boss_hit_passed.connect(_on_GlobalLevel_boss_hit_passed)
	GlobalStage.boss_heal_passed.connect(_on_GlobalLevel_boss_heal_passed)
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_used_bomb)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalPlayer_player_used_bomb_stop)
	
	reset_waiters()




func set_sprite(data:BossSpriteData):
	Sprite = data.get_sprite()
	Sprite.animation_finished.connect(_on_Sprite_animation_finished)
	add_child(Sprite)
	
	%Enemy.set_shape(data.get_hitbox())


func disable():
	self.hide()
	%Enemy.disable()
	
	active = false


func enable():
	self.show()
	%Enemy.enable()
	
	active = true


func disable_collider():
	%Enemy.disable()
	active = false


func enable_collider():
	%Enemy.enable()
	active = true


func toggle_bomb_immunity(enable:bool=true):
	self.bomb_immunity = enable


func charge_on(charge:ParticleData) -> void:
	ChargeParticles = charge.create_particle()
	ChargeParticles.one_shot = false
	ChargeParticles.explosiveness = 0
	self.add_child(ChargeParticles)
	
	ChargeParticles.set_emitting(true)


func charge_off() -> void:
	if ChargeParticles:
		ChargeParticles.set_emitting(false)
	ChargeParticles.queue_free()


func spell_effect(spell:ParticleData) -> void:
	var spell_particles = spell.create_particle()
	self.add_child(spell_particles)


func custom_animation(animation:String) -> void:
	Sprite.play_custom_animation(animation)


func return_animation() -> void:
	Sprite.play_return_animation()


func reset_animation() -> void:
	Sprite.play_default()


func move_boss(position:Vector2, time:float) -> Tween:
	if MoveTween:
		MoveTween.kill()
	MoveTween = self.create_tween()
	MoveTween.tween_property(self, "position", position, time)
	return MoveTween


func create_waiter(time:float=1.0) -> IntervalTweener:
	return Waiters.create_tween().tween_interval(time)


func reset_waiters() -> void:
	if Waiters:
		Waiters.queue_free()
	Waiters = Node2D.new()
	self.add_child(Waiters)


func special_function(name:String, args:Array=[]):
	Sprite.special_function(name, args)




func _on_Enemy_collider_hit(damage):
	if invincibility: return
	
	GlobalStage.boss_hit.emit(damage)


func _on_Enemy_collider_entered(_other, other_identity):
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()


func _on_GlobalLevel_boss_hit_passed():
	if not active: return
	
	Sprite.flash()
	%Sound_Hit.play()


func _on_GlobalLevel_boss_heal_passed():
	Sprite.flash(0.2, Color(0, 1, 0, 1))


func _on_GlobalPlayer_player_used_bomb(_spell_name):
	if bomb_immunity:
		invincibility = true
		Sprite.special_function("Invincibility_Sprite_On")


func _on_GlobalPlayer_player_used_bomb_stop():
	invincibility = false
	Sprite.special_function("Invincibility_Sprite_Off")


func _on_Sprite_animation_finished():
	animation_finished.emit()
