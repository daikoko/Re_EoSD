extends Node2D

const SPRITE := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaDarkGlow.png")

const A_LAYER_DISTANCE = 180.0
const A_LAYER_SPAWN_COUNT = 36
const A_LAYER_BULLET_SPEED = 40
const A_LAYER_LINEAR_DELAY = 1.2
const A_LAYER_LINEAR_TIME = 1.2
const A_LAYER_LINEAR_SPEED = 160

const B_LAYER_DISTANCE = 120.0
const B_LAYER_SPAWN_COUNT = 12
const B_LAYER_BULLET_SPEED = 0
const B_LAYER_LINEAR_DELAY = 0.5
const B_LAYER_LINEAR_TIME = 2.4
const B_LAYER_LINEAR_SPEED = 160
const B_LAYER_ROTATION_OFFSET = 15

const C_LAYER_DISTANCE = 60.0
const C_LAYER_SPAWN_COUNT = 0
const C_LAYER_BULLET_SPEED = 0
const C_LAYER_LINEAR_DELAY = 1.2
const C_LAYER_LINEAR_TIME = 1.2
const C_LAYER_LINEAR_SPEED = 80
const C_LAYER_ROTATION_OFFSET = 15

var time_limit:float
var time:float
var first:bool

var RNG:RandomNumberGenerator
var ClearTween:Tween
var linked_sprite:Node2D

var clear:bool = false




func _ready() -> void:
	%Sprite.scale = Vector2.ZERO


func _process(delta:float) -> void:
	time += delta
	if time >= (time_limit / 2) and first == false:
		first = true
		spawn()
	if time >= time_limit:
		queue_free()
	
	%Sprite.scale = Vector2.ONE * 0.4 * sin(PI * (time / time_limit))
	linked_sprite.global_transform = %Sprite.global_transform




func spawn():
	if GlobalStage.is_current_stage_clear():
		return
	
	var angle
	
	angle = RNG.randf_range(0, TAU)
	for _i in A_LAYER_SPAWN_COUNT:
		GlobalPool.bullet_linear_spawned.emit(
			GlobalShooter.SPADE_MAGENTA, 
			Transform2D(
				angle, 
				self.position + Vector2.RIGHT.rotated(angle) * A_LAYER_DISTANCE
			),
			A_LAYER_BULLET_SPEED, 0, 0, 0,
			A_LAYER_LINEAR_DELAY, A_LAYER_LINEAR_TIME, A_LAYER_LINEAR_SPEED
		)
		
		angle += (TAU / A_LAYER_SPAWN_COUNT)
	
	angle = RNG.randf_range(0, TAU)
	for _i in B_LAYER_SPAWN_COUNT:
		GlobalPool.bullet_linear_spawned.emit(
			GlobalShooter.SEED_RED, 
			Transform2D(
				angle + deg_to_rad(B_LAYER_ROTATION_OFFSET), 
				self.position + Vector2.RIGHT.rotated(angle) * B_LAYER_DISTANCE
			),
			B_LAYER_BULLET_SPEED, 0, 0, 0,
			B_LAYER_LINEAR_DELAY, B_LAYER_LINEAR_TIME, B_LAYER_LINEAR_SPEED
		)
		GlobalPool.bullet_linear_spawned.emit(
			GlobalShooter.SEED_RED, 
			Transform2D(
				angle - deg_to_rad(B_LAYER_ROTATION_OFFSET), 
				self.position + Vector2.RIGHT.rotated(angle) * B_LAYER_DISTANCE
			),
			B_LAYER_BULLET_SPEED, 0, 0, 0,
			B_LAYER_LINEAR_DELAY, B_LAYER_LINEAR_TIME, B_LAYER_LINEAR_SPEED
		)
		
		angle += (TAU / B_LAYER_SPAWN_COUNT)
	
	angle = RNG.randf_range(0, TAU)
	for _i in C_LAYER_SPAWN_COUNT:
		GlobalPool.bullet_linear_spawned.emit(
			GlobalShooter.SEED_RED, 
			Transform2D(
				angle + deg_to_rad(C_LAYER_ROTATION_OFFSET), 
				self.position + Vector2.RIGHT.rotated(angle) * C_LAYER_DISTANCE
			),
			C_LAYER_BULLET_SPEED, 0, 0, 0,
			C_LAYER_LINEAR_DELAY, C_LAYER_LINEAR_TIME, C_LAYER_LINEAR_SPEED
		)
		GlobalPool.bullet_linear_spawned.emit(
			GlobalShooter.SEED_RED, 
			Transform2D(
				angle - deg_to_rad(C_LAYER_ROTATION_OFFSET), 
				self.position + Vector2.RIGHT.rotated(angle) * C_LAYER_DISTANCE
			),
			C_LAYER_BULLET_SPEED, 0, 0, 0,
			C_LAYER_LINEAR_DELAY, C_LAYER_LINEAR_TIME, C_LAYER_LINEAR_SPEED
		)
		
		angle += (TAU / C_LAYER_SPAWN_COUNT)


func get_glow() -> Sprite2D:
	linked_sprite = Sprite2D.new()
	linked_sprite.texture = SPRITE
	linked_sprite.scale = Vector2.ZERO
	
	return linked_sprite



func _on_Collider_collider_entered(_other:Collider, other_identity:String) -> void:
	if (
			other_identity == "PlayerHitbox" and 
			not GlobalStage.is_current_player_bomb() and 
			not GlobalStage.is_current_stage_clear()
		):
		
		GlobalPlayer.player_hit.emit()


func _on_Self_tree_exiting() -> void:
	linked_sprite.queue_free()
