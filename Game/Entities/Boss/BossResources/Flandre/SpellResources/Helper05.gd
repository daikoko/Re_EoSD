extends Node2D

const TIME_START := 0.2

const TIME_DURATION_MIN := 1.2
const TIME_DURATION_MAX := 1.8

const TIME_END_MIN := 1.2
const TIME_END_MAX := 1.6

const ROTATION_SPEED_MIN := 240.0
const ROTATION_SPEED_MAX := 300.0

var rotation_speed:float
var wheel_direction:int = 1
var pointer_direction:int = 1

var RNG:RandomNumberGenerator
var disabled:bool

const HELPER_06 := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper06.tscn")

signal finished_round




func _ready():
	%Wheel.scale = Vector2.ZERO
	%Wheel.modulate.a = 0
	%Pointer.modulate.a = 0


func _process(delta:float) -> void:
	%Wheel.rotation += rotation_speed * delta




func start():
	var StartTween = self.create_tween().set_parallel()
	StartTween.tween_property(%Wheel,   "scale",      Vector2.ONE, 0.2)
	StartTween.tween_property(%Wheel,   "modulate:a", 1.0,         0.2)
	StartTween.tween_property(%Pointer, "modulate:a", 1.0,         0.2)
	
	pointer_loop()


func fire(
		fire_count:int,
		bullet_speed:float, 
		bullet_speed_range:float
	):
	
	if disabled: return
	
	var time_duration =         RNG.randf_range(TIME_DURATION_MIN,  TIME_DURATION_MAX)
	var time_end =              RNG.randf_range(TIME_END_MIN,       TIME_END_MAX)
	var rotation_speed_target = deg_to_rad(
									RNG.randf_range(ROTATION_SPEED_MIN, ROTATION_SPEED_MAX)
								)
	
	var indices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
	var indices_shuffled = shuffle(indices)
	var count = RNG.randf_range(8, 10)
	for i in count:
		var shooter = HELPER_06.instantiate()
		shooter.RNG = RNG
		shooter.rotation = (TAU / 12) * indices_shuffled[i]
		%Wheel.add_child(shooter)
		
		if i > 2: shooter.mute = true
		shooter.start(
			TIME_START + time_duration,
			time_end,
			fire_count,
			bullet_speed, 
			bullet_speed_range
		)
	
	var WheelTween = self.create_tween()
	WheelTween.tween_property(self, "rotation_speed", rotation_speed_target * wheel_direction, TIME_START)
	WheelTween.tween_interval(                                                                 time_duration)
	WheelTween.tween_property(self, "rotation_speed", 0,                                       time_end)
	await WheelTween.finished
	
	wheel_direction *= -1
	
	finished_round.emit()


func pointer_loop():
	if disabled: return
	
	var PointerTween = self.create_tween()
	PointerTween.tween_property(%Pointer, "position:y", -5 - (5 * pointer_direction), 0.1)
	await PointerTween.finished
	
	pointer_direction *= -1
	
	pointer_loop()


func disable():
	disabled = true
	
	%Blinkers.queue_free()
	
	var DisableTween = self.create_tween().parallel()
	DisableTween.tween_property(%Wheel,   "scale",      Vector2.ZERO, 0.2)
	DisableTween.tween_property(%Wheel,   "modulate:a", 0.0,          0.2)
	DisableTween.tween_property(%Pointer, "modulate:a", 0.0,          0.2)




func shuffle(list:Array) -> Array:
	var list_new:Array = []
	var size = list.size()
	for _i in size:
		var rand_index = RNG.randi_range(0, list.size() - 1)
		list_new.append(list[rand_index])
		list.remove_at(rand_index)
	
	return list_new
