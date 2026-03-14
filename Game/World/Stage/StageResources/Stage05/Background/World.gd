extends Node3D

var speed := 3
var time:float = 0

signal update_position(mov)
signal update_camera(rot)




func _ready() -> void:
	%Dummy.hide()


func _process(delta):
	var direction:Vector3 = Vector3.ZERO
	direction.z += 1
	
	time += delta
	%Camera.rotation.z = deg_to_rad(2 * sin(0.3 * time))
	
	direction = direction.normalized()
	update_position.emit(speed * direction * delta)
	update_camera.emit(%Camera.rotation)
