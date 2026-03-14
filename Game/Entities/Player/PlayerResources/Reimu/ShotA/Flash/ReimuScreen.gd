extends Node2D

const ROTATION_SPEED_01 := 150.0
const ROTATION_SPEED_02 := -120.0
const ROTATION_SPEED_03 := 90.0




func _ready():
	%Sprite_01.modulate.a = 0
	%Sprite_02.modulate.a = 0
	%Sprite_03.modulate.a = 0
	%Animator.play("Flash")


func _process(delta):
	%Sprite_01.rotation += deg_to_rad(ROTATION_SPEED_01) * delta
	%Sprite_02.rotation += deg_to_rad(ROTATION_SPEED_02) * delta
	%Sprite_03.rotation += deg_to_rad(ROTATION_SPEED_03) * delta




func flash_over() -> void:
	queue_free()
