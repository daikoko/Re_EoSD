extends Node2D

var ball_velocity:Vector2 = Vector2.ZERO

const ROTATION_SPEED := -120




func _ready():
	%Ball.global_position = Vector2(340, 90)
	
	%BallSprite.modulate.a = 0
	%BallSprite.scale = Vector2.ZERO
	
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_bomb_used)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalPlayer_player_bomb_used_stop)


func _physics_process(delta:float) -> void:
	%BallSprite.rotation += deg_to_rad(ROTATION_SPEED) * delta
	
	var collision = %Ball.move_and_collide(ball_velocity * delta)
	if collision:
		ball_velocity = ball_velocity.bounce(collision.get_normal())
		collision.get_collider().get_parent().hit()




func start(
		speed:float
	):
	
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.tween_property(%BallSprite, "scale",      Vector2.ONE, 0.8)
	SelfTween.tween_property(%BallSprite, "modulate:a", 1,           0.8)
	await SelfTween.finished
	
	ball_velocity = Vector2.RIGHT.rotated(TAU / 6) * speed


func hit():
	pass


func disable():
	GlobalPool.particle_bomb_spawned.emit(%Ball.global_position, Color(1,0,0,1))
	queue_free()


func get_ball() -> Node2D:
	return %Ball




func _on_Enemy_collider_entered(_other, other_identity:) -> void:
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()


func _on_GlobalPlayer_player_bomb_used(_spellname):
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.tween_property(%BallSprite, "modulate:a", 0.4, 0.4)


func _on_GlobalPlayer_player_bomb_used_stop():
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.tween_property(%BallSprite, "modulate:a", 1.0, 0.4)
