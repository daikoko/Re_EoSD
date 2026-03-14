extends Sprite2D


func _ready():
	%Animator.play("Bomb")




func _on_Animator_animation_finished(_anim_name):
	queue_free()
