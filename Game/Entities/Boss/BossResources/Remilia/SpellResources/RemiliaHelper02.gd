extends Node2D

var all_lasers:Array = []
var primary_lasers:Array = []
var secondary_lasers:Array = []

signal internal_finished_round




func _ready():
	all_lasers = [
		%Laser01, 
		%Laser02, 
		%Laser03, 
		%Laser04, 
		%Laser05
	]
	primary_lasers = [
		%Laser01
	]
	secondary_lasers = [
		%Laser02, 
		%Laser03, 
		%Laser04, 
		%Laser05
	]




func fire_primary(
		laser:LaserData,
		laser_duration:float, 
		laser_delay_time:float=1.0, 
		laser_grow_time:float=0.4, 
		laser_shrink_time:float=0.2
	) -> void:
	
	for laser_object in primary_lasers:
		laser_object.activate(
			laser.color, laser.weight,
			laser_duration, 
			laser_delay_time, 
			laser_grow_time, 
			laser_shrink_time
	)


func fire_secondary(
		laser:LaserData,
		laser_duration:float, 
		laser_delay_time:float=1.0, 
		laser_grow_time:float=0.4, 
		laser_shrink_time:float=0.2
	) -> void:
	
	for laser_object in secondary_lasers:
		laser_object.activate(
			laser.color, laser.weight,
			laser_duration, 
			laser_delay_time, 
			laser_grow_time, 
			laser_shrink_time
	)


func disable() -> void:
	for laser_object in all_lasers:
		laser_object.immediate_stop()


func play_sound():
	%FireSound.play()
