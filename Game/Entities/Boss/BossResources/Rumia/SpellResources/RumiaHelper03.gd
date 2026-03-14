extends Node2D

const HELPER_04 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper04.tscn")
const HELPER_05 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper05.tscn")
const HELPER_06 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper06.tscn")

const DISTANCE_01 := 200
const SPAWNS_01 := 5

const DISTANCE_02 := 580
const SPAWNS_02 := 8

const DISTANCE_03 := 960
const SPAWNS_03 := 11

const TIME_LIMIT := 5.6
const TIME_WAIT := 4.0

var RNG:RandomNumberGenerator
var Canvas:Node2D

signal shooter_finished




func _ready() -> void:
	Canvas = HELPER_04.instantiate()
	GlobalStage.request_add_object.emit(Canvas)




func fire() -> void:
	var angle
	
	angle = RNG.randf_range(0, TAU)
	for i in SPAWNS_01:
		var spawner = HELPER_05.instantiate()
		spawner.position = self.global_position + Vector2.RIGHT.rotated(
			angle + (TAU * (float(i) / SPAWNS_01))
		) * DISTANCE_01
		spawner.RNG = RNG
		spawner.time_limit = TIME_LIMIT
		Canvas.add_spawner(spawner)
		
		var sprite = spawner.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
	
	angle = RNG.randf_range(0, TAU)
	for i in SPAWNS_02:
		var spawner = HELPER_05.instantiate()
		spawner.position = self.global_position + Vector2.RIGHT.rotated(
			angle + (TAU * (float(i) / SPAWNS_02))
		) * DISTANCE_02
		spawner.RNG = RNG
		spawner.time_limit = TIME_LIMIT
		Canvas.add_spawner(spawner)
		
		var sprite = spawner.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
	
	angle = RNG.randf_range(0, TAU)
	for i in SPAWNS_03:
		var spawner = HELPER_05.instantiate()
		spawner.position = self.global_position + Vector2.RIGHT.rotated(
			angle + (TAU * (float(i) / SPAWNS_03))
		) * DISTANCE_03
		spawner.RNG = RNG
		spawner.time_limit = TIME_LIMIT
		Canvas.add_spawner(spawner)
		
		var sprite = spawner.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
	
	await create_tween().tween_interval(TIME_WAIT).finished
	
	shooter_finished.emit()


func disable() -> void:
	Canvas.queue_free()
	queue_free()
