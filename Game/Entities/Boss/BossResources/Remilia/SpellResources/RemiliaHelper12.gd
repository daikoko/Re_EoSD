extends Node2D

var linear_delay:float
var linear_time:float
var linear_speed:float

var distance_max:float

var speed:float
var distance_current:float





func _ready() -> void:
	var LinearTween = create_tween()
	LinearTween.tween_interval(linear_delay)
	LinearTween.tween_property(self, "speed", linear_speed, linear_time)


func _process(delta: float) -> void:
	self.position += self.transform.x * speed * delta
	
	distance_current += speed * delta
	if distance_current > distance_max:
		%BulletDull.deactivate()




func build(
		bullet:BulletData,
		initial_speed:float,
		linear_delay:float,
		linear_time:float,
		linear_speed:float,
		distance_max:float
	):
	
	%BulletDull.data = bullet
	
	self.linear_delay = linear_delay
	self.linear_time =  linear_time
	self.linear_speed = linear_speed
	self.distance_max = distance_max
	
	self.speed = initial_speed




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
