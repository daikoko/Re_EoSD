extends Node2D

const CIRNO_SHARD := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper04.tscn")

const DURATION := 3.2
const SPAWN_ANGLE_LOW := -10.0
const SPAWN_ANGLE_HIGH := 30.0
const RELEASE_ANGLE_START := 90.0
const RELEASE_ANGLE_RANGE_A := 30
const RELEASE_ANGLE_RANGE_B := 0
const DISTANCE_RANGE := 300.0
var RNG:RandomNumberGenerator

var SPEED_RANGE := 20.0

var low:int = 1
var release_angle_start:float
var disabled:bool = false

signal finished_round




func _ready():
	%ShooterA.rotation = deg_to_rad(SPAWN_ANGLE_LOW)
	%ShooterB.rotation = deg_to_rad(180 - SPAWN_ANGLE_LOW)
	release_angle_start = RELEASE_ANGLE_START




func change_low() -> void:
	low *= -1


func fire(
	fire_count:int, stack_count:int,
	full_travel_speed:float, release_speed:float
	) -> void:
	
	var spawn_angle_change = (SPAWN_ANGLE_HIGH - SPAWN_ANGLE_LOW) / fire_count
	var travel_time = DISTANCE_RANGE / full_travel_speed
	
	%FireTimer.wait_time = DURATION / fire_count
	%FireTimer.start()
	for i in fire_count:
		
		%Sound.play()
		for j in stack_count:
			if disabled:
				return
			
			var travel_distance = (j + 1) * (DISTANCE_RANGE / stack_count)
			var release_time = 0.1 + (j * 0.1)
			var release_angle = release_angle_start + (j * (RELEASE_ANGLE_RANGE_B / fire_count))
			
			var CirnoShard_R = CIRNO_SHARD.instantiate()
			GlobalStage.request_add_object.emit(CirnoShard_R)
			CirnoShard_R.transform = %ShooterA.global_transform
			CirnoShard_R.point = (i + j) % 4 == 0
			CirnoShard_R.activate(
				travel_distance,
				travel_time,
				release_time,
				release_speed + RNG.randf_range(-SPEED_RANGE, SPEED_RANGE),
				release_angle + RNG.randf_range(-2, 2)
			)
			
			var CirnoShard_L = CIRNO_SHARD.instantiate()
			GlobalStage.request_add_object.emit(CirnoShard_L)
			CirnoShard_L.transform = %ShooterB.global_transform
			CirnoShard_L.point = (i + j + 1) % 4 == 0
			CirnoShard_L.activate(
				travel_distance,
				travel_time,
				release_time,
				release_speed + RNG.randf_range(-SPEED_RANGE, SPEED_RANGE),
				180 - release_angle + RNG.randf_range(-2, 2)
			)
		
		%ShooterA.rotation += deg_to_rad(low * spawn_angle_change)
		%ShooterB.rotation -= deg_to_rad(low * spawn_angle_change)
		release_angle_start += low * (RELEASE_ANGLE_RANGE_A / fire_count)
		await %FireTimer.timeout
	
	finished_round.emit()


func disable() -> void:
	disabled = true
