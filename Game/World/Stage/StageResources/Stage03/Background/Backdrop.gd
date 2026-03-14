extends Node3D


func approach(mansion:float, wall:float, time:float) -> void:
	var ApproahTween = self.create_tween().set_parallel(true)
	ApproahTween.tween_property(%Mansion, "position:z", mansion, time)
	ApproahTween.tween_property(%Wall, "position:z", wall, time)




func _on_World_update_camera(rot):
	%Camera.rotation = rot
