extends Node2D

var point:bool

var released:bool
var current_distance:float

var travel_speed:float
var travel_distance:float

var release_time:float
var release_speed:float
var release_angle:float




func _ready():
	%BulletDull.bullet_deactivate.connect(_on_BulletDull_bullet_deactivate)


func _process(delta):
	if not released:
		position += transform.x * travel_speed * delta
		current_distance += travel_speed * delta
		if current_distance > travel_distance:
			%Timer.start()
			set_process(false)
	else:
		position += transform.x * release_speed * delta




func activate(travel_distance:float, travel_time:float, release_time:float, release_speed:float, release_angle:float) -> void:
	self.travel_speed = travel_distance / travel_time
	self.travel_distance = travel_distance
	self.release_time = release_time
	self.release_speed = release_speed
	self.release_angle = deg_to_rad(release_angle)
	
	released = false
	%Timer.wait_time = release_time
	set_process(true)




func _on_BulletDull_bullet_deactivate():
	queue_free()


func _on_Timer_timeout():
	released = true
	global_rotation = release_angle
	
	set_process(true)
