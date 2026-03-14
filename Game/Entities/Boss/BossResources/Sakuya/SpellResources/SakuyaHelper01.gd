extends Node2D

const HELPER02 := preload("res://Game/Entities/Boss/BossResources/Sakuya/SpellResources/SakuyaHelper02.tscn")
const POINTER := preload("res://Game/Objects/Shooters/Shooter/Pointer.tscn")

var spawners:Array = []
var rotation_speed:float

var disabled:bool = false
var RNG:RandomNumberGenerator

signal finished_round




func _process(delta:float) -> void:
	self.rotation += deg_to_rad(rotation_speed) * delta




func create_self(
		primary_layout_spawner_count:int, 
		primary_layout_shot_range:float,
	):
	
	var angle = -primary_layout_shot_range / 2
	var angle_step = primary_layout_shot_range / (primary_layout_spawner_count - 1)
	for i in primary_layout_spawner_count:
		var pointer = POINTER.instantiate()
		pointer.rotation = deg_to_rad(angle)
		spawners.append(pointer)
		self.add_child(pointer)
		
		angle += angle_step


func fire(
		travel_distance_curve:Curve, travel_time:float,
		travel_distance_min:float, travel_distance_max:float,
		primary_fire_count:int,
		primary_fire_duration:float,
		secondary_data:BulletData,
		secondary_layout_spawner_count:int,
		secondary_layout_shot_range:float,
		secondary_bullets:Array[RowData_Column],
		secondary_bullet_speed:float,
		secondary_spawn_stack_count:int,
		secondary_spawn_stack_speed:float,
		secondary_aim:bool
	):
		
	if disabled:
		pass
	
	var fire_time = primary_fire_duration / primary_fire_count
	%FireTimer.wait_time = fire_time
	%FireTimer.start()
	
	for i in primary_fire_count:
		
		var travel_distance_multiplier = (
			travel_distance_max -
			(travel_distance_max - travel_distance_min) * (float(i) / primary_fire_count)
		)
		
		for j in spawners.size():
			var spawner = spawners[j]
			
			var SecondaryShooter:Shooter_Basic = GlobalShooter.create_basic_shooter(
				secondary_layout_spawner_count,
				1, 360, secondary_layout_shot_range,
				0
			)
			SecondaryShooter.immunity_time = 4.0
			SecondaryShooter.RNG = RNG
			
			var complex_bullet = HELPER02.instantiate()
			complex_bullet.MainShooter = SecondaryShooter
			complex_bullet.add_child(SecondaryShooter)
			
			if j != 0:
				complex_bullet.mute = true
			
			GlobalStage.request_add_object.emit(complex_bullet)
			
			complex_bullet.activate(
				spawner.global_transform,
				secondary_data,
				travel_distance_curve,travel_distance_multiplier, 
				travel_time - (i * fire_time),
				secondary_bullets,
				secondary_bullet_speed,
				secondary_spawn_stack_count,
				secondary_spawn_stack_speed,
				secondary_aim
			)
		
		%FireSound.play()
		await %FireTimer.timeout
	
	%FireTimer.stop()
	
	finished_round.emit()


func disable():
	disabled = true
