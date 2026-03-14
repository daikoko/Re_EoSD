extends Node3D

var speed := 4

signal update_position(mov)
signal update_camera(rot)




func _ready():
	%Camera.rotation_degrees = Vector3(-90, 0, 0)




func _process(delta):
	var direction:Vector3 = Vector3.ZERO
	direction.z += 1
	
	direction = direction.normalized()
	update_position.emit(speed * direction * delta)
	update_camera.emit(%Camera.rotation)




func turn() -> void:
	var BackgroundTween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
	BackgroundTween.tween_property(self, "speed", 8, 2.4)
	BackgroundTween.tween_property(%Camera, "rotation_degrees", Vector3.ZERO, 2.4)


func practice() -> void:
	var BackgroundTween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
	BackgroundTween.tween_property(self, "speed", 8, 0)
	BackgroundTween.tween_property(%Camera, "rotation_degrees", Vector3.ZERO, 0)
