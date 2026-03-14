extends Node2D

const BULLET_DULL := preload("res://Game/Objects/Bullets/BulletScripts/BulletDull.tscn")
const BRIGHT_WHITE := GlobalShooter.BRIGHT_WHITE
const SEED_YELLOW := GlobalShooter.SEED_YELLOW

const ROT_SPEED := 90.0

const ROT_TOTAL := 60
const SPEED_MIN := 160
const SPEED_MAX := 240

const DELAY := 0.8

const MINOR_SPAWNER_COUNT := 8
const MINOR_BULLET_SPEED := 180.0
const MINOR_STACK_COUNT := 3
const MINOR_STACK_SPEED := 30.0
const MINOR_TIME := 2.0

const MAJOR_SPAWNER_COUNT := 8
const MAJOR_FIRE_COUNT := 12
const MAJOR_BULLET_SPEED := 200.0
const MAJOR_DELAY_ADD := 0.1
const MAJOR_TIME := 1.4

var RNG:RandomNumberGenerator


func _ready():
	%Rotater.scale = Vector2.ZERO


func _process(delta):
	%Rotater.rotation += delta * deg_to_rad(ROT_SPEED)




func set_rotater(RNG:RandomNumberGenerator, delay:float, major:bool):
	self.RNG = RNG
	
	var center = BULLET_DULL.instantiate()
	center.data = BRIGHT_WHITE
	center.visibility_immunity = true
	%Rotater.add_child(center)
	
	for i in 6:
		var angle = TAU * (float(i) / 6)
		var pos = Vector2(24, 0).rotated(angle)
		var side = BULLET_DULL.instantiate()
		side.data = SEED_YELLOW
		side.visibility_immunity = true
		side.position = pos
		side.rotation = angle
		%Rotater.add_child(side)
	
	var HelperTween = create_tween()
	HelperTween.tween_property(%Rotater, "scale", Vector2.ONE, 0.2)
	HelperTween.tween_interval(DELAY + delay)
	HelperTween.tween_property(%Rotater, "scale", Vector2.ZERO, 0.4)
	HelperTween.finished.connect(_on_HelperTween_finished)
	
	if major:
		spawn_bullet_major(delay)
	else:
		spawn_bullet_minor(delay)


func spawn_bullet_minor(delay:float):
	var angle_step = TAU / MINOR_SPAWNER_COUNT
	
	%Guide.rotation = RNG.randf_range(0, TAU)
	for i in MINOR_SPAWNER_COUNT:
		for j in MINOR_STACK_COUNT:
			var speed = MINOR_BULLET_SPEED + (j * MINOR_STACK_SPEED)
			GlobalPool.bullet_linear_spawned.emit(BRIGHT_WHITE, %Guide.global_transform,
				0, 0, 0, 0,
				DELAY + delay, MINOR_TIME, speed
			)
		%Guide.rotation += angle_step


func spawn_bullet_major(delay:float):
	var bullets = []
	var bullets_base = [
		GlobalShooter.SEED_RED,
		GlobalShooter.SEED_YELLOW,
		GlobalShooter.SEED_GREEN,
		GlobalShooter.SEED_CYAN,
		GlobalShooter.SEED_BLUE,
		GlobalShooter.SEED_MAGENTA,
	]
	var interval = floori(MAJOR_FIRE_COUNT / 6)
	for i in MAJOR_FIRE_COUNT:
		var num = floori(i / interval)
		bullets.append(
			bullets_base[num]
		)
	
	var angle_step_spawner = TAU / MAJOR_SPAWNER_COUNT
	var angle_step_fire = PI / MAJOR_FIRE_COUNT
	
	var right = RNG.randf_range(0, TAU)
	var left = right
	
	for i in MAJOR_FIRE_COUNT:
		var real_delay = delay + DELAY + (i * MAJOR_DELAY_ADD)
		var real_right = right
		var real_left = left
		for j in MAJOR_SPAWNER_COUNT:
			%Guide.rotation = real_right
			GlobalPool.bullet_linear_spawned.emit(bullets[i], %Guide.global_transform,
				0, 0, 0, 0,
				real_delay, MAJOR_TIME, MAJOR_BULLET_SPEED
			)
			
			%Guide.rotation = real_left
			GlobalPool.bullet_linear_spawned.emit(bullets[i], %Guide.global_transform,
				0, 0, 0, 0,
				real_delay, MAJOR_TIME, MAJOR_BULLET_SPEED
			)
			
			real_right += angle_step_spawner
			real_left -= angle_step_spawner
		
		right += angle_step_fire
		left -= angle_step_fire


func spawn_bullets_major():
	var count = 6
	
	var bullets_base = [
		GlobalShooter.SMALL_RED,
		GlobalShooter.SMALL_YELLOW,
		GlobalShooter.SMALL_GREEN,
		GlobalShooter.SMALL_CYAN,
		GlobalShooter.SMALL_BLUE,
		GlobalShooter.SMALL_MAGENTA,
	]
	var interval = floori(count / 6)
	var bullets = []
	for i in count:
		var num = floori(i / interval)
		bullets.append(
			bullets_base[num]
		)




func _on_HelperTween_finished():
	queue_free()
