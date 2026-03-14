extends Node2D

const BEAM := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaLine.png")
const GLOW := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaLineGlow.png")

const LASER_DELAY := 0.8
const LASER_GROW := 0.4
const LASER_TIME := 1.2
const LASER_END := 0.4

var RNG:RandomNumberGenerator
var Beam:Node2D
var Glow:Node2D

var A_Shooter:Shooter_Sine
var A_Bullets:Array[RowData_Column]
const A_FIRE_COUNT := 32
const A_FIRE_DURATION := 1.2
const A_BULLET_SPEED := 920.0
const A_SINE_COMPRESSION := 2.0
const A_SINE_AMPLITUDE := 40.0

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
const B_LAYOUT_SPAWNER_COUNT := 1
const B_FIRE_COUNT := 12
const B_FIRE_DURATION := 0
const B_BULLET_SPEED := 240.0
const B_BULLET_SPEED_RANGE := 40
const B_SPAWN_STACK_COUNT := 4
const B_SPAWN_STACK_SPEED := 20

var active:bool




func _ready() -> void:
	%Collider.disable()
	
	%Beam.scale.x = 0
	%Warning.hide()
	
	A_Shooter = GlobalShooter.create_sine_shooter(
		GlobalShooter.build_basic()
	)
	A_Shooter.RNG = RNG
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	%Shooters.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(B_LAYOUT_SPAWNER_COUNT)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_MAGENTA
			])
		])
	]
	%Shooters.add_child(B_Shooter)
	
	fire()


func _process(_delta:float) -> void:
	Beam.global_transform = %Beam.global_transform
	Glow.global_transform = %Beam.global_transform




func fire():
	var LaserTween = create_tween()
	LaserTween.tween_interval(LASER_DELAY)
	await LaserTween.finished
	
	%Line.hide()
	%Sound.play()
	%Collider.enable()
	
	LaserTween = create_tween()
	LaserTween.tween_property(%Beam, "scale:x", 0.8, LASER_GROW)
	LaserTween.tween_interval(LASER_TIME)
	await LaserTween.finished
	
	%Collider.disable()
	
	if active:
		shoot()
	
	LaserTween = create_tween()
	LaserTween.tween_property(%Beam, "scale:x", 0.0, LASER_END)
	await LaserTween.finished
	
	Beam.queue_free()
	Glow.queue_free()
	set_process(false)
	
	if not active:
		queue_free()


func activate():
	active = true


func shoot():
	%Animator.play("Blink")
	await %Animator.animation_finished
	
	B_Shooter.rotation_random = true
	B_Shooter.rotation_random_range = Vector2(
		deg_to_rad(-150),
		deg_to_rad(30)
	)
	B_Shooter.fire_round_stack(
		B_Bullets,
		B_FIRE_COUNT, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE,
		0, 0, 
		B_SPAWN_STACK_COUNT, B_SPAWN_STACK_SPEED
	)
	
	A_Shooter.immunity_time = 2.0
	A_Shooter.flash_time = 0
	A_Shooter.rotation = deg_to_rad(-90)
	A_Shooter.fire_round(
		A_Bullets,
		A_FIRE_COUNT, A_FIRE_DURATION,
		A_BULLET_SPEED,
		A_SINE_AMPLITUDE,
		A_SINE_COMPRESSION,
		true
	)
	await A_Shooter.finished_round
	
	queue_free()


func get_beam():
	Beam = Sprite2D.new()
	Beam.texture = BEAM
	Beam.position = Vector2(0, 390)
	Beam.scale.x = 0
	
	return Beam


func get_glow():
	Glow = Sprite2D.new()
	Glow.texture = GLOW
	Glow.position = Vector2(0, 390)
	Glow.scale.x = 0
	
	return Glow




func _on_Collider_collider_entered(_other: Collider, other_identity: String) -> void:
	if (
			other_identity == "PlayerHitbox" and 
			not GlobalStage.is_current_player_bomb() and 
			not GlobalStage.is_current_stage_clear()
		):
		
		GlobalPlayer.player_hit.emit()
