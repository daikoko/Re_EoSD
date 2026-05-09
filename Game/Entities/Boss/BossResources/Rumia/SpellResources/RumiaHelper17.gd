extends Node2D

const HELPER_18 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper18.tscn")

const START_LINE_COUNT := 12
const START_BULLET_COUNT := 32
const START_LINE_LENGTH := 780.0
const START_HEIGHT_MIN := 60.0
const START_HEIGHT_MAX := 180.0
const START_HUE_MIN := 0.75
const START_HUE_MAX := 0.33

const ARC_LENGTH := 40.0

var A_Shooter:Shooter_Sine
var A_Bullets:Array[RowData_Column]
const A_LAYOUT_SPAWNER_COUNT := 5
const A_LAYOUT_SHOT_RANGE := 40.0
const A_FIRE_COUNT := 24
const A_FIRE_DURATION := 0.8
const A_BULLET_SPEED := 800.0
const A_SINE_AMPLITUDE := 40.0
const A_SINE_COMPRESSION := 2.0
const A_SINE_DOUBLE := true

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
const B_LAYOUT_SPAWNER_COUNT := 4
const B_LAYOUT_SHOT_RANGE := 60.0
const B_FIRE_COUNT := 1
const B_FIRE_DURATION := 0.0
const B_BULLET_SPEED := 300.0
const B_SPAWN_STACK_COUNT := 4
const B_SPAWN_STACK_SPEED := 60.0
const B_SHOOTER_ROUND_COUNT := 10
const B_SHOOTER_ROUND_DURATION := 1.2

var RNG:RandomNumberGenerator

signal start_finished
signal shooting_finished




func _ready() -> void:
	%Warning.value = (ARC_LENGTH / 360) * 100
	%Warning.hide()
	
	%Warning.pivot_offset = (%Warning.size / 2)
	%Warning.position = - (%Warning.size / 2)
	%Warning.rotation = (PI / 2) - (deg_to_rad(ARC_LENGTH) / 2)
	%Warning.modulate.a = 0.4
	
	%Path.position = Vector2(
		0,
		START_HEIGHT_MIN + ((START_HEIGHT_MAX - START_HEIGHT_MIN) / 2)
	)
	
	A_Shooter = GlobalShooter.create_sine_shooter(
		GlobalShooter.build_basic(
			A_LAYOUT_SPAWNER_COUNT,
			1, 360,
			A_LAYOUT_SHOT_RANGE
		)
	)
	A_Shooter.RNG = RNG
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	%Pointer.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_LAYOUT_SPAWNER_COUNT,
		1, 360,
		B_LAYOUT_SHOT_RANGE
	)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_MAGENTA
			])
		])
	]
	%Shot.add_child(B_Shooter)




func start():
	for i in START_LINE_COUNT:
		var right = RNG.randf_range(-40, 0)
		var height = START_HEIGHT_MIN + (i * ((START_HEIGHT_MAX - START_HEIGHT_MIN) / START_LINE_COUNT))
		var hue = START_HUE_MIN + (i * (START_HUE_MAX - START_HUE_MIN) / START_LINE_COUNT)
		
		spawn_line(right, height, hue)
		await create_tween().tween_interval(0.1).finished
	
	await create_tween().tween_interval(0.4).finished
	
	start_finished.emit()


func spawn_line(right_start:float, height:float, hue:float):
	var A_offset = RNG.randf_range(0, 400)
	var B_offset = RNG.randf_range(0, 400)
	
	for i in START_BULLET_COUNT:
		var distance = right_start + (i * (START_LINE_LENGTH / START_BULLET_COUNT))
		
		var bullet = HELPER_18.instantiate()
		bullet.position = Vector2(
			distance,
			height
		)
		bullet.origin = Vector2(
			distance,
			height
		)
		bullet.A_offset = A_offset
		bullet.B_offset = B_offset
		bullet.set_color(hue)
		GlobalStage.request_add_object.emit(bullet)
		
		await create_tween().tween_interval(0.02).finished


func fire():
	%Main.progress_ratio = RNG.randf_range(0.1, 0.9)
	
	var center = (GlobalStage.VIEWPORT_SIZE / 2) + (Vector2.DOWN * 600)
	var vector = center - %Pointer.global_position
	var angle = RNG.randf_range(
		vector.angle() - deg_to_rad(30),
		vector.angle() + deg_to_rad(30)
	)
	
	%Pointer.rotation = angle
	%Animator.play("Blink")
	await %Animator.animation_finished
	
	A_Shooter.fire_round(
		A_Bullets,
		A_FIRE_COUNT, A_FIRE_DURATION,
		A_BULLET_SPEED,
		A_SINE_AMPLITUDE, A_SINE_COMPRESSION,
		A_SINE_DOUBLE
	)
	await create_tween().tween_interval(A_FIRE_DURATION * 0.75).finished
	
	for _i in B_SHOOTER_ROUND_COUNT:
		%Side.progress_ratio = RNG.randf_range(0.1, 0.9)
		%Shot.global_rotation = deg_to_rad(90)
		B_Shooter.fire_round_stack(
			B_Bullets,
			B_FIRE_COUNT, B_FIRE_DURATION,
			B_BULLET_SPEED, 0,
			0, 0,
			B_SPAWN_STACK_COUNT, B_SPAWN_STACK_SPEED
		)
		await create_tween().tween_interval(B_SHOOTER_ROUND_DURATION / B_SHOOTER_ROUND_COUNT).finished
	
	shooting_finished.emit()


func disable():
	queue_free()
