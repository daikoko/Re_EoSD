extends Node2D

var damage:float




func _ready():
	%Line01.scale.x = 0
	$Line01/Bomb.disable()
	
	%Line02.scale.x = 0
	$Line02/Bomb.disable()
	
	%Line03.scale.x = 0
	$Line03/Bomb.disable()
	
	%Line04.scale.x = 0
	$Line04/Bomb.disable()
	
	%Line05.scale.x = 0
	$Line05/Bomb.disable()
	
	
	%Animator.play("Flash")




func flash_over() -> void:
	queue_free()




func _on_Bomb_collider_entered(collider, identity):
	if identity == "Enemy":
		collider.hit(damage)
