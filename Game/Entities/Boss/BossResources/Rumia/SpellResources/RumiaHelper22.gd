extends Node2D

const SPRITE := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaDarkGlow.png")
const TIME_LIMIT := 2.0

var MainShooter:Shooter_Linear
var MainBullets:Array[RowData_Column]
const LAYOUT_SPAWNER_COUNT := 1
const FIRE_COUNT := 64
const FIRE_DURATION := 0
const BULLET_SPEED := 160.0
const BULLET_SPEED_RANGE := 80.0

var RNG:RandomNumberGenerator
var ClearTween:Tween
var linked_sprite:Node2D

var target_scale:float
var grow:bool
var time:float




func _ready():
	target_scale = RNG.randf_range(0.2, 0.4)
	
	%WarningSprite.scale = Vector2.ONE * target_scale
	%WarningSprite.hide()
	
	%MainSprite.scale = Vector2.ZERO
	
	MainShooter = GlobalShooter.create_linear_shooter(LAYOUT_SPAWNER_COUNT)
	MainShooter.RNG = RNG
	MainBullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	self.add_child(MainShooter)
	
	start()


func _process(delta:float) -> void:
	if grow:
		time += delta
		if time >= TIME_LIMIT:
			grow = false
			linked_sprite.hide()
			shoot()
	
	%MainSprite.scale = Vector2.ONE * target_scale * sin(PI * (time / TIME_LIMIT))
	linked_sprite.global_transform = %MainSprite.global_transform




func start():
	%Animator.play("Blink")
	await %Animator.animation_finished
	
	grow = true


func shoot():
	MainShooter.rotation_random = true
	MainShooter.fire_round(
		MainBullets,
		FIRE_COUNT, FIRE_DURATION,
		BULLET_SPEED, BULLET_SPEED_RANGE
	)
	await create_tween().tween_interval(1.0).finished
	
	queue_free()


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
