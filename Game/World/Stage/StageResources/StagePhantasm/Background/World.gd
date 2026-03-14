extends Node3D

var speed := 4
var time:float = 0

signal update_position(mov)
signal update_camera(rot)




func _ready():
	%Camera.rotation_degrees = Vector3(0, 0, 0)




func _process(delta):
	var direction:Vector3 = Vector3.ZERO
	direction.z += 1
	
	time += delta
	%Camera.rotation.z = deg_to_rad(2 * sin(0.3 * time))
	
	direction = direction.normalized()
	update_position.emit(speed * direction * delta)
	update_camera.emit(%Camera.rotation)




func reverse() -> void:
	var BackgroundTween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
	BackgroundTween.tween_property(self, "speed", -8, 4.0)


func practice() -> void:
	var BackgroundTween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
	BackgroundTween.tween_property(self, "speed", 8, 0)
	BackgroundTween.tween_property(%Camera, "rotation_degrees", Vector3.ZERO, 0)
