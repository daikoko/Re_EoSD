extends Node2D

var rotation_speed:float
var shooters:Array = []


func _process(delta):
	rotation += delta * rotation_speed




func set_shooters(
		shooter_count:int, distance:float,
		RNG:RandomNumberGenerator
	):
	
	for i in shooter_count:
		var angle = TAU * (float(i) / shooter_count)
		var shooter = GlobalShooter.create_basic_shooter(
			1
		)
		shooter.position = Vector2(distance, 0).rotated(angle)
		shooter.rotation_random = true
		shooter.RNG = RNG
		shooters.append(shooter)
		
		if i != 1:
			shooter.mute = true
		
		self.add_child(shooter)


func fire_round(
		bullets:Array[RowData_Column], 
		fire_count:int, fire_duration:float,
		bullet_speed:float, bullet_speed_range:float
	):
	
	for shooter in shooters:
		shooter.fire_round(
			bullets,
			fire_count, fire_duration,
			bullet_speed, bullet_speed_range
		)
