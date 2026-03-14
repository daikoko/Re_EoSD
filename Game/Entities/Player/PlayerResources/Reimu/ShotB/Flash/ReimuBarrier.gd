extends Node2D

var damage:float




func _ready():
	%Horizontal.scale.y = 0
	%Vertical.scale.x = 0
	%Animator.play("Flash")




func set_flash(damage:float) -> void:
	self.damage = damage




func flash_over() -> void:
	queue_free()




func _on_Bomb_collider_entered(collider, identity):
	if identity == "Enemy":
		collider.hit(damage)
