extends Node2D

var MainShooter:Shooter_Basic
var Bullets:Array[RowData_Column]
var RNG:RandomNumberGenerator

var fire_count:int
var bullet_speed:float
var bullet_speed_range:float




func _ready():
	%Sprite.modulate.a = 0
	%Sprite.scale = Vector2.ZERO
	
	var SelfTween = self.create_tween().set_parallel()
	SelfTween.tween_property(%Sprite, "modulate:a", 1,           0.4)
	SelfTween.tween_property(%Sprite, "scale",      Vector2.ONE, 0.4)
	SelfTween.tween_property(%Sprite, "rotation",   TAU,         0.4)
	
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_bomb_used)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalPlayer_player_bomb_used_stop)




func prepare(
		fire_count:int,
		bullet_speed:float,
		bullet_speed_range:float
	):
	
	MainShooter = GlobalShooter.create_basic_shooter()
	MainShooter.RNG = RNG
	MainShooter.rotation_random = true
	Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	self.add_child(MainShooter)
	
	self.fire_count = fire_count
	self.bullet_speed = bullet_speed
	self.bullet_speed_range = bullet_speed_range


func hit():
	%Sprite.hide()
	
	GlobalPool.particle_bomb_spawned.emit(self.global_position, Color(1,0,0,1))
	MainShooter.fire_round(
		Bullets,
		fire_count, 0,
		bullet_speed, bullet_speed_range
	)
	await self.create_tween().tween_interval(0.8).finished
	
	queue_free()


func disable():
	GlobalPool.particle_bomb_spawned.emit(self.global_position, Color(1,0,0,1))
	queue_free()




func _on_Enemy_collider_entered(_other, other_identity:) -> void:
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()


func _on_GlobalPlayer_player_bomb_used(_spellname):
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.tween_property(%BallSprite, "modulate:a", 0.4, 0.4)


func _on_GlobalPlayer_player_bomb_used_stop():
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.tween_property(%BallSprite, "modulate:a", 1.0, 0.4)
