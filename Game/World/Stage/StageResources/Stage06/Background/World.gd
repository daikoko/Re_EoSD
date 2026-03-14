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
	
	direction = direction.normalized()
	update_position.emit(speed * direction * delta)
	update_camera.emit(%Camera.rotation, %Camera.position)




func pan_up():
	var CameraTween = self.create_tween()
	CameraTween.tween_property(%Camera,"rotation",Vector3(PI/2,0,0),2.6)
	CameraTween.parallel().tween_property(%Camera,"position",Vector3(0,10,5),2.6)
	CameraTween.chain().tween_property(%Camera,"position",Vector3(0,10,12),1.4)
