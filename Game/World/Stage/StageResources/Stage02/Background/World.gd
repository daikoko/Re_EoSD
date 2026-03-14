extends Node3D

var speed:float = 1.6
var time:float = 0

signal update_position(mov)
signal update_camera(rot)
signal update_fog(density)




func _ready():
	%WorldEnvironment.environment.fog_density = 0.16


func _process(delta):
	var direction:Vector3 = Vector3.ZERO
	direction.z += cos(deg_to_rad(-150))
	direction.x += sin(deg_to_rad(-150))
	direction = direction.normalized()
	
	time += delta
	%Camera.rotation.z = deg_to_rad(4 * sin(0.6 * time))
	
	update_position.emit(speed * direction * delta)
	update_camera.emit(%Camera.rotation)
	update_fog.emit(%WorldEnvironment.environment.fog_density)




func raise_density(density:float, time:float) -> void:
	var DensityTween = create_tween().set_ease(Tween.EASE_IN)
	DensityTween.tween_property(%WorldEnvironment.environment, 'fog_density', density, time)
