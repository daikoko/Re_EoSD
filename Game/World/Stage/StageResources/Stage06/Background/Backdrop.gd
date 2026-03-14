extends Node3D


func _on_World_update_camera(rot, pos=Vector3.ZERO):
	%Camera.rotation = rot
	%Camera.position = pos
