extends Node2D

var origin:Vector2
var distance:float
var angle:float

var max_speed:float
var velocity:Vector2
var velocity_saved:Vector2

var position_previous:Vector2
var released:bool = false




func _process(delta:float) -> void:
	if released == false:
		var position_target = origin + (Vector2.RIGHT.rotated(angle) * distance)
		var velocity = (position_target - position_previous) * (1 / delta)
		# velocity = velocity.normalized() * max_speed
		# print(velocity.length())
		
		self.position += velocity * delta
		self.rotation = velocity.angle()
		
		if velocity.length() != 0:
			velocity_saved = velocity
	
	else:
		self.position += velocity * delta
	
	position_previous = position




func set_data(data:BulletData) -> void:
	%BulletDull.data = data


func activate(
		origin:Vector2,
		max_speed:float,
		distance_max:float, distance_time:float, distance_extra:float,
		angle_start:float, angle_max:float, angle_delay:float, angle_time:float
	) -> void:
	
	position_previous = origin
	self.origin = origin
	self.max_speed = max_speed
	self.angle = angle_start
	%BulletDull.visibility_immunity = true
	
	var DistanceTween = self.create_tween()
	DistanceTween.tween_property(self, "distance", distance_max, distance_time)
	DistanceTween.tween_property(self, "distance", distance_extra, angle_time)
	
	var RotationTween = self.create_tween()
	RotationTween.tween_interval(angle_delay)
	RotationTween.tween_property(self, "angle", angle_start + angle_max, angle_time)
	
	await RotationTween.finished
	
	released = true
	velocity = velocity_saved
	%BulletDull.visibility_immunity = false




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
