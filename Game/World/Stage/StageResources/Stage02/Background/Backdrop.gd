extends Node3D


func _on_World_update_camera(rot):
	%Camera.rotation = rot


func _on_World_update_fog(density:float):
	%WorldEnvironment.environment.fog_density = density + 0.4
