extends Node2D

const HELPER_04 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper04.tscn")
const HELPER_16 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper16.tscn")

const LASER_COUNT_01 := 6
const LASER_COUNT_02 := 7
const MAX_FIRES := 4

const FIRE_DURATION := 0.8

var RNG:RandomNumberGenerator
var Canvas:Node2D

signal shooting_finished




func _ready():
	Canvas = HELPER_04.instantiate()
	GlobalStage.request_add_object.emit(Canvas)




func fire(direction:int):
	var laser_count
	if direction == 1:
		laser_count = LASER_COUNT_01
	else:
		laser_count = LASER_COUNT_02
	
	var interval = 700 / (laser_count - 1) * direction
	var place = 350 - (350 * direction)
	var current_fires:int = 0
	
	for _i in laser_count:
		var laser = HELPER_16.instantiate()
		laser.position = Vector2(place, 0)
		laser.RNG = RNG
		Canvas.add_spawner(laser)
		
		var beam = laser.get_beam()
		Canvas.add_spawner(beam)
		
		var glow = laser.get_glow()
		glow.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(glow)
		
		if RNG.randi_range(0, 1) == 1 and current_fires < MAX_FIRES:
			laser.activate()
			current_fires += 1
		
		place += interval
		await create_tween().tween_interval(FIRE_DURATION / laser_count).finished
	
	shooting_finished.emit()


func disable():
	Canvas.queue_free()
	queue_free()
