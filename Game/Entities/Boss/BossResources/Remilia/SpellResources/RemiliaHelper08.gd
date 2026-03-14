extends Node2D

var bullet:BulletData

var origin:Vector2
var direction:Vector2
var distance:float
var time:float
var delay:float

var distance_current:float
var rotation_speed:float

signal bullet_deleted(bullet, direction, distance, time, delay, rotation_speed)




func _ready() -> void:
	self.create_tween().tween_property(self, "distance_current", distance, time)


func _process(delta:float) -> void:
	self.position = origin + (direction.rotated(rotation) * distance_current)
	self.rotation += rotation_speed * delta




func build(
		bullet:BulletData,
		origin:Vector2, 
		direction:Vector2, 
		distance:float, 
		time:float, 
		delay:float, 
		rotation_speed:float
	) -> void:
	
	%BulletDull.data = bullet
	self.bullet = bullet
	
	self.origin = origin
	self.direction = direction
	self.distance = distance
	self.time = time
	self.delay = delay
	
	self.rotation_speed = rotation_speed




func _on_BulletDull_bullet_deactivate() -> void:
	bullet_deleted.emit(bullet, direction, distance, time, delay, rad_to_deg(rotation_speed))
	
	queue_free()
