extends Node2D

var target:Marker3D

signal cleared




func _process(_delta:float) -> void:
	var vec = target.global_position
	
	self.position.x = vec.x * 80
	self.position.y = vec.y * 80
	%BulletDull.z_index = (
		20 +
		snappedi(vec.z * 9, 1)
	)




func _on_BulletDull_bullet_deactivate() -> void:
	cleared.emit()
	queue_free()
