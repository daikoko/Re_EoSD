extends Node2D

var origin:Vector2
var time:float

var A_offset:float
var A_COMPRESSION := 0.3
var A_AMPLITUDE := 10.0
var A_TIME_MOD := 120.0

var B_offset:float
var B_COMPRESSION := 0.1
var B_AMPLITUDE := 20.0
var B_TIME_MOD := 100.0



func _process(delta: float) -> void:
	var A_sin = A_AMPLITUDE * sin((0.01 * TAU) * A_COMPRESSION * (A_offset + origin.x + (A_TIME_MOD * time)))
	var B_sin = B_AMPLITUDE * sin((0.01 * TAU) * B_COMPRESSION * (B_offset + origin.x + (B_TIME_MOD * time)))
	
	position = Vector2(
		origin.x,
		origin.y + A_sin + B_sin
	)
	
	time += delta




func set_color(hue:float):
	%Sprite.modulate = Color.from_hsv(hue, 1, 1, 1)


func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
