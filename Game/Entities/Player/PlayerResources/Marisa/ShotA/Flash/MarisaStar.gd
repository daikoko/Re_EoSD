extends Node2D

var delay:bool = true
var waiting:bool = false

var velocity:Vector2
var damage:float




func _process(delta):
	if waiting:
		pass
	elif delay:
		delay = false
	elif !delay and !%Visibility.is_on_screen():
		%DeleteTimer.start()
		waiting = true
		set_process(false)
	
	position += velocity * delta




func set_bullet(transform:Transform2D, damage:float, speed:float) -> void:
	self.transform = transform
	self.damage = damage
	self.velocity = Vector2.RIGHT.rotated(transform.get_rotation()) * speed




func _on_Bomb_collider_entered(collider, identity):
	if identity == "Enemy":
		collider.hit(damage)


func _on_DeleteTimer_timeout():
	queue_free()
