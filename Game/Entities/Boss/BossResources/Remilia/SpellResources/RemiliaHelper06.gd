extends Node2D

var velocity:Vector2




func _ready() -> void:
	%ShadowHandler.effect_start()


func _process(delta:float) -> void:
	self.position += velocity * delta




func build(
		velocity:Vector2
	):
	
	self.velocity = velocity




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
