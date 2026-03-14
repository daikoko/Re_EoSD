extends Node2D

const SPEED := 720.0

const BULLET_DATA := preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightRed.tres")
const BULLET_SPEED := 160
const LINEAR_DELAY := 0.2
const LINEAR_DURATION := 1.2
const LINEAR_SPEED_CHANGE := 0
const LINEAR_DIR_CHANGE := [
	 30,
	 10,
	-10,
	-30
]

var markers = []
var mute:bool

var RNG:RandomNumberGenerator




func _ready() -> void:
	markers = [
		%Marker01, 
		%Marker02, 
		%Marker03, 
		%Marker04
	]


func _process(delta:float) -> void:
	self.position += transform.x * SPEED * delta




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()


func _on_ImmunityTimer_timeout() -> void:
	%BulletDull.visibility_immunity = false


func _on_FireTimer_timeout() -> void:
	for i in markers.size():
		GlobalPool.bullet_linear_spawned.emit(
			BULLET_DATA, markers[i].global_transform,
			BULLET_SPEED + RNG.randf_range(-20, 20), 0, 0, 0,
			LINEAR_DELAY + RNG.randf_range(-0.1, 0.1), 
			LINEAR_DURATION,
			LINEAR_SPEED_CHANGE,
			deg_to_rad(LINEAR_DIR_CHANGE[i] + RNG.randf_range(-10, 10))
		)
	
	if mute == false: %Sound.play()
