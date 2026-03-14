extends Node2D

var direction:Vector2
var turning:float
var speed:float
var rotation_speed:float




func _ready() -> void:
	direction = self.transform.x


func _process(delta):
	self.position += direction * speed * delta
	
	direction += transform.y * turning * delta
	direction = direction.normalized()
	
	self.rotation = direction.angle()
	
	%BulletDull.rotation += rotation_speed * delta




func build(
		bullet_data:BulletData,
		bullet_speed:float,
		bullet_turning:float,
		bullet_rotation_speed:float
	) -> void:
	
	%BulletDull.data = bullet_data
	self.speed = bullet_speed
	self.turning = bullet_turning
	self.rotation_speed = bullet_rotation_speed




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
