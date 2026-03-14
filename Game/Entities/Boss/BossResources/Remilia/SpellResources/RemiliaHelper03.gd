extends Node2D

var spawners:Array = []
var RNG:RandomNumberGenerator

var disabled:bool = false

const HELPER_04 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper04.tscn")
const DISTANCE := 40.0

signal round_finished()




func build(
		primary_layout_spawner_count:int,
		primary_layout_shot_range:float,
	) -> void:
	
	var angle = - deg_to_rad(primary_layout_shot_range) / 2
	var angle_step = deg_to_rad(primary_layout_shot_range) / (primary_layout_spawner_count - 1)
	
	for _i in primary_layout_spawner_count:
		var spawner = Marker2D.new()
		spawner.position = Vector2.RIGHT.rotated(angle) * DISTANCE
		spawner.rotation = angle
		
		spawners.append(spawner)
		self.add_child(spawner)
		
		angle += angle_step


func fire(
		secondary_layout_spawner_count:int,
		secondary_shooter_speed:float,
		secondary_shooter_rotation_speed:float,
		secondary_fire_count:int,
		secondary_fire_duration:float,
		secondary_bullet_speed:float
	) -> void:
	
	if disabled:
		return
	
	self.rotation = GlobalPlayer.angle_to_player(self.global_position)
	
	%Sound.play()
	var counter = 0
	for spawner in spawners:
		var shooter = HELPER_04.instantiate()
		shooter.RNG = RNG
		shooter.build(
			Vector2.RIGHT.rotated(spawner.global_rotation) * secondary_shooter_speed,
			deg_to_rad(secondary_shooter_rotation_speed),
			secondary_layout_spawner_count,
			secondary_fire_count,
			secondary_fire_duration,
			secondary_bullet_speed
		)
		
		shooter.position = spawner.global_position
		counter += 1
		if counter != 1: shooter.mute = true
		
		GlobalStage.request_add_object.emit(shooter)


func disable() -> void:
	disabled = true
