extends Node2D

const SPRITE := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaBeamGlow.png")
const YELLOW_STAR := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/Bullet_RumiaStarYellow.tres")

var A_Shooter:Shooter_Linear
var A_Bullets:Array[RowData_Column]
const A_LAYOUT_SPAWNER_COUNT := 24
const A_BULLET_SPEED := 0.0
const A_LINEAR_TIME := 1.2
const A_LINEAR_SPEED := 160.0

var B_Shooter:Shooter_Tween
var B_Bullets:Array[RowData_Bullet]
const B_BULLET_ROTATION := 45.0
const B_LAYOUT_SPAWNER_COUNT := 16
const B_TWEEN_RELEASE_SPEED := 120
const B_TWEEN_RELEASE_ANGLE := 45.0
@export_subgroup("First")
@export var B_tween_distance_01:Curve
@export var B_tween_rotation_01:Curve
@export_subgroup("Second")
@export var B_tween_distance_02:Curve
@export var B_tween_rotation_02:Curve
@export_subgroup("Third")
@export var B_tween_distance_03:Curve
@export var B_tween_rotation_03:Curve

var time_delay:float
var time_grow:float
var time_wait:float
var time_end:float

var DarkTween:Tween
var ClearTween:Tween
var linked_sprite:Node2D

var clear:bool = false

var mute:bool = false




func _ready() -> void:
	%Line.show()
	%Sprite.scale = Vector2(1, 0)
	
	%Collider.disable()
	
	A_Shooter = GlobalShooter.create_linear_shooter(A_LAYOUT_SPAWNER_COUNT)
	A_Shooter.mute = mute
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	%Shooters.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(B_LAYOUT_SPAWNER_COUNT)
	)
	B_Shooter.mute = mute
	B_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.SPADE_MAGENTA
		])
	]
	%Shooters.add_child(B_Shooter)
	
	fire()


func _process(_delta: float) -> void:
	if linked_sprite:
		linked_sprite.global_transform = %Sprite.global_transform




func fire() -> void:
	DarkTween = create_tween()
	DarkTween.tween_interval(time_delay)
	await DarkTween.finished
	
	%Line.hide()
	%Collider.enable()
	
	DarkTween = create_tween()
	DarkTween.tween_property(%Sprite, "scale:y", 1.0, time_grow)
	DarkTween.tween_interval(time_wait)
	await DarkTween.finished
	
	shoot()
	
	DarkTween = create_tween()
	DarkTween.tween_property(%Sprite, "scale:y", 0.0, time_end)


func shoot():
	if GlobalStage.is_current_stage_clear():
		return
	
	var total_delay_linear = time_end + 0.4
	var total_delay_tween = time_end + 0.8
	
	%Shooters.position.x = 240
	A_Shooter.fire_row(
		A_Bullets[0],
		A_BULLET_SPEED, 0,
		0, 0, 
		total_delay_linear, A_LINEAR_TIME,
		A_LINEAR_SPEED
	)
	B_Shooter.fire_row(
		B_Bullets[0],
		B_BULLET_ROTATION, 0,
		total_delay_tween, 
		B_tween_distance_01,
		B_tween_rotation_01,
		B_TWEEN_RELEASE_SPEED, 
		B_TWEEN_RELEASE_ANGLE,
		false,
		false,
		null,
		false
	)
	
	%Shooters.position.x = 480
	A_Shooter.fire_row(
		A_Bullets[0],
		A_BULLET_SPEED, 0,
		0, 0, 
		total_delay_linear, A_LINEAR_TIME,
		A_LINEAR_SPEED
	)
	B_Shooter.fire_row(
		B_Bullets[0],
		B_BULLET_ROTATION, 0,
		total_delay_tween, 
		B_tween_distance_02,
		B_tween_rotation_02,
		B_TWEEN_RELEASE_SPEED, 
		B_TWEEN_RELEASE_ANGLE,
		false,
		false,
		null,
		true
	)
	
	%Shooters.position.x = 720
	A_Shooter.fire_row(
		A_Bullets[0],
		A_BULLET_SPEED, 0,
		0, 0, 
		total_delay_linear, A_LINEAR_TIME,
		A_LINEAR_SPEED
	)
	B_Shooter.fire_row(
		B_Bullets[0],
		B_BULLET_ROTATION, 0,
		total_delay_tween, 
		B_tween_distance_03,
		B_tween_rotation_03,
		B_TWEEN_RELEASE_SPEED, 
		B_TWEEN_RELEASE_ANGLE,
		false,
		false,
		null,
		false
	)


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
