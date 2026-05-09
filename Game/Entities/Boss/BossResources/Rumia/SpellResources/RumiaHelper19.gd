extends Node2D

const HELPER_04 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper04.tscn")
const HELPER_20 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper20.tscn")

const ORIGIN := Vector2(350, 390)
const ROTATION_SPEED := 20.0
const DURATION := 15.0

var RNG:RandomNumberGenerator
var Canvas:Node2D




func _ready() -> void:
	Canvas = HELPER_04.instantiate()
	GlobalStage.request_add_object.emit(Canvas)




func fire():
	fire_a()
	
	await create_tween().tween_interval(DURATION).finished
	
	fire_b()
	
	await create_tween().tween_interval(DURATION).finished
	
	fire_c()
	
	await create_tween().tween_interval(DURATION).finished
	
	fire_d()


func fire_a():
	var angle = RNG.randf_range(0, 360.0)
	var angle_step = 360.0 / 2
	
	for i in 2:
		var spawner = HELPER_20.instantiate()
		spawner.RNG = RNG
		spawner.origin = ORIGIN
		spawner.distance = 500
		spawner.max_scale = 0.8
		spawner.current_rotation = angle
		spawner.rotation_speed = ROTATION_SPEED
		spawner.duration = DURATION
		Canvas.add_spawner(spawner)
		
		var sprite = spawner.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
		
		if i >= 0:
			spawner.create_shooter(
				GlobalShooter.BRIGHT_RED,
				24, 
				360,
				2,
				80.0,
				deg_to_rad(RNG.randf_range(0, TAU)),
				deg_to_rad(RNG.randf_range(20, 40))
			)
		
		angle += angle_step


func fire_b():
	var angle = RNG.randf_range(0, 360.0)
	var angle_step = 360.0 / 3
	
	for i in 3:
		var spawner = HELPER_20.instantiate()
		spawner.RNG = RNG
		spawner.origin = ORIGIN
		spawner.distance = 500
		spawner.max_scale = 0.7
		spawner.current_rotation = angle
		spawner.rotation_speed = ROTATION_SPEED
		spawner.duration = DURATION
		Canvas.add_spawner(spawner)
		
		var sprite = spawner.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
		
		if i >= 0:
			spawner.create_shooter(
				GlobalShooter.SPADE_MAGENTA,
				8, 
				310,
				6,
				80.0,
				deg_to_rad(RNG.randf_range(0, TAU)),
				- deg_to_rad(RNG.randf_range(10, 20))
			)
		
		angle += angle_step


func fire_c():
	var angle = RNG.randf_range(0, 360.0)
	var angle_step = 360.0 / 4
	
	for i in 4:
		var spawner = HELPER_20.instantiate()
		spawner.RNG = RNG
		spawner.origin = ORIGIN
		spawner.distance = 500
		spawner.max_scale = 0.6
		spawner.current_rotation = angle
		spawner.rotation_speed = ROTATION_SPEED
		spawner.duration = DURATION
		Canvas.add_spawner(spawner)
		
		var sprite = spawner.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
		
		if i % 2 == 0:
			spawner.create_shooter(
				GlobalShooter.BRIGHT_RED,
				18, 
				260,
				1,
				60.0,
				deg_to_rad(RNG.randf_range(0, TAU)),
				deg_to_rad(RNG.randf_range(20, 40))
			)
		else:
			spawner.create_shooter(
				GlobalShooter.SPADE_MAGENTA,
				6, 
				260,
				4,
				60.0,
				deg_to_rad(RNG.randf_range(0, TAU)),
				- deg_to_rad(RNG.randf_range(10, 20))
			)
		
		angle += angle_step


func fire_d():
	var angle = RNG.randf_range(0, 360.0)
	var angle_step = 360.0 / 6
	
	for i in 6:
		var spawner = HELPER_20.instantiate()
		spawner.RNG = RNG
		spawner.origin = ORIGIN
		spawner.distance = 440
		spawner.max_scale = 0.4
		spawner.current_rotation = angle
		spawner.rotation_speed = ROTATION_SPEED
		spawner.duration = 2000
		Canvas.add_spawner(spawner)
		
		var sprite = spawner.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
		
		if i % 2 == 0:
			spawner.create_shooter(
				GlobalShooter.MEDIUM_RED,
				12, 
				180,
				1,
				60.0,
				deg_to_rad(RNG.randf_range(0, TAU)),
				deg_to_rad(RNG.randf_range(20, 40))
			)
		else:
			spawner.create_shooter(
				GlobalShooter.SPADE_MAGENTA,
				6, 
				180,
				4,
				60.0,
				deg_to_rad(RNG.randf_range(0, TAU)),
				- deg_to_rad(RNG.randf_range(10, 20))
			)
		
		angle += angle_step


func disable():
	Canvas.queue_free()
