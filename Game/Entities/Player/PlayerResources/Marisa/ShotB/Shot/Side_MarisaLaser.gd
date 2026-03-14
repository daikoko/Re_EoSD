extends Node2D

var active:bool = false
var firing:bool = false
var enabled:bool = false
var LaserTween:Tween


signal laser_hit(collider,identity)




func _ready():
	%Beam.scale.x = 0
	%Origin.scale = Vector2.ZERO
	%Collider.disable()
	
	stop()




func activate() -> void:
	active = true
	
	if firing:
		set_tween()
		LaserTween.tween_property(%Beam, "scale:x", 1.0, 0.2)
		LaserTween.tween_property(%Origin, "scale", Vector2.ONE * 0.02, 0.2)


func deactivate() -> void:
	active = false
	
	if firing:
		set_tween()
		LaserTween.tween_property(%Beam, "scale:x", 0.0, 0.2)
		LaserTween.tween_property(%Origin, "scale", Vector2.ZERO * 0.02, 0.2)


func start() -> void:
	firing = true
	
	if active:
		set_tween()
		LaserTween.tween_property(%Beam, "scale:x", 1.0, 0.2)
		LaserTween.tween_property(%Origin, "scale", Vector2.ONE * 0.02, 0.2)


func stop() -> void:
	firing = false
	
	if active:
		set_tween()
		LaserTween.tween_property(%Beam, "scale:x", 0.0, 0.2)
		LaserTween.tween_property(%Origin, "scale", Vector2.ZERO * 0.02, 0.2)


func enable() -> void:
	enabled = true
	%Collider.enable()


func disable() -> void:
	enabled = false
	%Collider.disable()




func set_tween() -> void:
	if LaserTween:
		LaserTween.kill()
	LaserTween = create_tween().set_parallel(true)


func _on_Collider_collider_entered(collider, identity):
	if active and firing:
		laser_hit.emit(collider,identity)
