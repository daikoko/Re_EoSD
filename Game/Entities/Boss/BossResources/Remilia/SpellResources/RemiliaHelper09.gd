extends Node2D

var RNG :RandomNumberGenerator
var disabled:bool

var spawners:Array = []

const HELPER_10 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper10.tscn")
const BULLET_DISTANCE := 800.0
const BULLET_ROTATION_SPEED := 30.0
const BULLET_TIME := 2.0




func build(
		layout_spawner_count:int,
	):
	
	var angle = 0
	var angle_step = TAU / layout_spawner_count
	for _i in layout_spawner_count:
		var spawner = Marker2D.new()
		spawner.position = Vector2.ZERO
		spawner.rotation = angle
		spawners.append(spawner)
		
		self.add_child(spawner)
		
		angle += angle_step


func fire(
		direction:int,
		fire_count:int,
		linear_delay:float,
		linear_time:float,
		linear_speed:float,
	):
	
	if disabled: return
	
	var first = true
	
	%Sound.play()
	for spawner in spawners:
		var bullet = HELPER_10.instantiate()
		bullet.position = self.global_position
		bullet.rotation = spawner.global_rotation
		bullet.build(
			self.global_position,
			Vector2.RIGHT.rotated(self.global_rotation),
			BULLET_DISTANCE,
			BULLET_TIME,
			deg_to_rad(BULLET_ROTATION_SPEED),
			direction,
			fire_count,
			linear_delay,
			linear_time,
			linear_speed
		)
		
		if first:
			first = false
		else:
			bullet.mute = true
		
		GlobalStage.request_add_object.emit(bullet)


func disable():
	disabled = true
