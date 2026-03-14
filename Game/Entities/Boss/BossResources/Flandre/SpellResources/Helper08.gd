extends Node2D




func _ready():
	%Sprite.position.y = -60




func set_sprite(texture:Texture2D):
	%Sprite.texture = texture


func turn_on():
	%Sprite.material.set_shader_parameter("flash_modifier", 1.0)


func turn_off():
	%Sprite.material.set_shader_parameter("flash_modifier", 0.0)
