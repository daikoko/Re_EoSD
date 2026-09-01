extends Node2D

var lasers:Array = []
var rotation_speed:float

const HELPER_02 = preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper02.tscn")
const SECONDAY_LASER_DURATION := 1.0
const DELAY := 3.0

var disabled:bool = false

signal finished_round




func _process(delta:float) -> void:
	self.rotation += deg_to_rad(rotation_speed) * delta




func build(
		spawner_count:int,
		distance:float
	):
	
	var pos = Vector2.RIGHT * distance
	var rot = 0
	var angle_step = TAU / spawner_count
	
	for _i in spawner_count:
		var laser = HELPER_02.instantiate()
		laser.position = pos
		laser.rotation = rot
		lasers.append(laser)
		self.add_child(laser)
		
		pos = pos.rotated(angle_step)
		rot += angle_step


func fire(
		primary_laser:LaserData,
		primary_fire_duration:float,
		secondary_laser:LaserData,
		secondary_fire_duration:float,
		secondary_delay:float
	):
	
	if disabled: return
	
	self.show()
	
	var secondary_laser_duration = SECONDAY_LASER_DURATION
	var primary_laser_duration = SECONDAY_LASER_DURATION + secondary_delay + primary_fire_duration
	
	var primary_time = primary_fire_duration / lasers.size()
	%FireTimer.wait_time = primary_time
	%FireTimer.start()
	
	play_sound()
	for laser in lasers:
		laser.fire_primary(
			primary_laser,
			primary_laser_duration
		)
		
		await %FireTimer.timeout
	
	%DelayTimer.wait_time = secondary_delay
	%DelayTimer.start()
	await %DelayTimer.timeout
	
	var secondary_time = secondary_fire_duration / lasers.size()
	%FireTimer.wait_time = secondary_time
	%FireTimer.start()
	
	play_sound()
	for laser in lasers:
		laser.fire_secondary(
			secondary_laser,
			secondary_laser_duration
		)
		await %FireTimer.timeout
	
	%DelayTimer.wait_time = DELAY
	%DelayTimer.start()
	await %DelayTimer.timeout
	
	self.hide()
	for laser in lasers:
		laser.disable()
	
	finished_round.emit()


func disable():
	disabled = true
	
	self.hide()
	for laser in lasers:
		laser.disable()
	
	%FireTimer.stop()
	%DelayTimer.stop()




func play_sound():
	await create_tween().tween_interval(1.0).finished
	
	if disabled: return
	
	%FireSound.play()
