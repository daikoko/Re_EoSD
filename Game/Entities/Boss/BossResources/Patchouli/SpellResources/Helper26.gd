extends Node2D

const START_TIME := 1.0
const ROTATION_SPEED := 60.0

signal start_finished




func _ready():
	%Sprite.modulate.a = 0
	%Sprite.scale = Vector2.ZERO


func _process(delta:float) -> void:
	%Sprite.rotation += deg_to_rad(ROTATION_SPEED) * delta




func start():
	var SpriteTween = self.create_tween().set_parallel(true)
	SpriteTween.tween_property(%Sprite, "scale",      Vector2.ONE * 0.8, START_TIME)
	SpriteTween.tween_property(%Sprite, "modulate:a", 1.0,               START_TIME)
	await SpriteTween.finished
	
	start_finished.emit()


func disable():
	var SpriteTween = self.create_tween().set_parallel(true)
	SpriteTween.tween_property(%Sprite, "scale",      Vector2.ZERO, START_TIME)
	SpriteTween.tween_property(%Sprite, "modulate:a", 0.0,         START_TIME)
