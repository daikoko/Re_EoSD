extends Node2D

const H_SPEED_CAP := 120.0

var velocity:Vector2
var rotation_speed:float

var h_acceleration:float
var direction:int = 1

var RNG:RandomNumberGenerator




func _process(delta:float) -> void:
	self.position += velocity * delta
	
	var h_speed = velocity.x
	h_speed = clampf(
		h_speed + (h_acceleration * delta), 
		-H_SPEED_CAP, 
		 H_SPEED_CAP
	)
	velocity = Vector2(
		h_speed,
		velocity.y
	)
	
	self.rotation += deg_to_rad(rotation_speed) * delta




func activate(
		y_speed:float,
		acceleration_time:float,
		rotation_speed:float
	) -> void:
	
	self.velocity = Vector2.DOWN * y_speed
	self.rotation_speed = rotation_speed
	
	direction = (RNG.randi_range(0, 1) * 2) - 1
	
	change_acceleration()
	%AccelerationTimer.wait_time = acceleration_time
	%AccelerationTimer.start()


func change_acceleration() -> void:
	h_acceleration = RNG.randf_range(80, 120) * direction
	direction *= -1




func _on_AccelerationTimer_timeout() -> void:
	change_acceleration()
	
	%BulletDull.visibility_immunity = false


func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
