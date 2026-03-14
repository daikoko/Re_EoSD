extends Node3D

var speed := 4

signal update_position(mov)
signal update_camera(rot)




func _ready() -> void:
	$WorldRepeater/WorldSliceA.hide()
	$WorldRepeater/WorldSliceA2.hide()


func _process(delta):
	var direction:Vector3 = Vector3.ZERO
	direction.z += 1
	
	direction = direction.normalized()
	update_position.emit(speed * direction * delta)
	update_camera.emit(%Camera.rotation)
