extends Node3D

const CAMERA_START_POSITION := Vector3(0, 8, 0)
const CAMERA_START_ROTATION := Vector3.ZERO

const CAMERA_RAISE_POSITION := Vector3(0, 26, 0)
const CAMERA_RAISE_ROTATION := Vector3(-20, 0, 0)

var speed := 4

signal update_position(mov)
signal update_camera(rot)




func _ready() -> void:
	$Dummy.hide()
	%Camera.position = CAMERA_START_POSITION
	%Camera.rotation_degrees = CAMERA_START_ROTATION


func _process(delta):
	var direction:Vector3 = Vector3.ZERO
	direction.z += 1
	
	direction = direction.normalized()
	update_position.emit(speed * direction * delta)
	update_camera.emit(%Camera.rotation)




func raise(time:float):
	var RaiseTween = create_tween().set_parallel(true)
	RaiseTween.tween_property(%Camera, "position", CAMERA_RAISE_POSITION, time)
	RaiseTween.tween_property(%Camera, "rotation_degrees", CAMERA_RAISE_ROTATION, time)
