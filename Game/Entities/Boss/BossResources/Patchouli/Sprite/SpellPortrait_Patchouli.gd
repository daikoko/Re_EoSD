extends Node2D

var mode:int

const ROTATION_SPEED := 45

var PortraitTween:Tween



func _ready():
	if mode == SpellPortrait_Data.CONFIGURATION.LEFT:
		%Animator.play("Left")
	elif mode == SpellPortrait_Data.CONFIGURATION.RIGHT:
		%Animator.play("Right")
	elif mode == SpellPortrait_Data.CONFIGURATION.MIDDLE:
		pass


func _process(delta: float) -> void:
	%Decor.rotation += deg_to_rad(ROTATION_SPEED) * delta




func set_portrait(data:SpellPortrait_Data) -> void:
	%Sprite.texture = data.texture
	%Sprite.offset = data.offset
	%Sprite.scale = data.scale
	self.mode = data.mode
	
	%Decor.texture = data.extra_texture




func _on_Animator_animation_finished(_anim_name) -> void:
	queue_free()
