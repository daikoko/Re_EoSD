extends Node2D

const HELPER_04 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper04.tscn")
const HELPER_10 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper10.tscn")
const HELPER_11 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper11.tscn")

const BEAM_COUNT := 6
const TIME_DELAY := 0.8
const TIME_GROW := 0.8
const TIME_WAIT := 1.8
const TIME_END := 0.4
const TIME_TOTAL := 3.8

var RNG:RandomNumberGenerator
var Canvas:Node2D

var direction:int = 1

signal shooter_finished




func _ready() -> void:
	Canvas = HELPER_04.instantiate()
	GlobalStage.request_add_object.emit(Canvas)




func fire():
	
	var main = HELPER_10.instantiate()
	main.position   = self.global_position
	main.direction  = direction
	main.time_delay = TIME_DELAY
	main.time_grow  = TIME_GROW
	main.time_wait  = TIME_WAIT
	main.time_end   = TIME_END
	
	
	
	var angle = RNG.randf_range(0, TAU)
	for i in BEAM_COUNT:
		var beam = HELPER_11.instantiate()
		beam.rotation   = angle
		beam.time_delay = TIME_DELAY
		beam.time_grow  = TIME_GROW
		beam.time_wait  = TIME_WAIT
		beam.time_end   = TIME_END
		if (i == 0) or (i == 4):
			beam.mute = true
		main.add_child(beam)
		
		var beam_sprite = beam.get_glow()
		beam_sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(beam_sprite)
		
		angle += TAU / BEAM_COUNT
	
	Canvas.add_spawner(main)
	
	var sprite = main.get_glow()
	sprite.modulate = Color(2, 1, 1, 1)
	Canvas.add_sprite(sprite)
	
	await self.create_tween().tween_interval(TIME_TOTAL).finished
	
	direction *= -1
	shooter_finished.emit()


func disable():
	queue_free()
	Canvas.queue_free()
