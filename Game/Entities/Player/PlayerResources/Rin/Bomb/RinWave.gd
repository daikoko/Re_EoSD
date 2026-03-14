extends Node2D

var damage:float


func _ready():
	%Bomb.scale = Vector2.ZERO
	%Bomb.modulate.a = 0
	
	%Animator.play("Bomb")




func _on_Bomb_collider_entered(other, other_identity):
	if other_identity == "Enemy":
		other.hit(damage)


func _on_Animator_animation_finished(_anim_name: StringName) -> void:
	queue_free()
