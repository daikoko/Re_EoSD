extends Node2D

const BULLET := preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneCyan.tres")
const SPEED := 240
const STEER_FORCE := 10
const BULLET_SPEED_RANGE := 40
const BULLET_DIR_RANGE := 12

var target:Node2D
var velocity:Vector2

var bullet_speed:float
var RNG:RandomNumberGenerator

var spawners:Array
var dir_offset:Array = [0, -BULLET_DIR_RANGE, BULLET_DIR_RANGE]

signal single_deactivate




func _ready():
	spawners = [
		%Marker01,
		%Marker02,
		%Marker03
	]


func _process(delta):
	var desired = global_position.direction_to(target.global_position) * SPEED
	var steer = velocity.direction_to(desired) * STEER_FORCE
	velocity = (velocity + steer).normalized() * SPEED
	
	position += velocity * delta
	rotation = velocity.angle()




func set_identity(identity:String):
	%Collider.identity = identity




func _on_FireTimer_timeout():
	for i in spawners.size():
		var adjusted_speed = RNG.randf_range(
			bullet_speed - BULLET_SPEED_RANGE,
			bullet_speed + BULLET_SPEED_RANGE
		)
		
		var dir = RNG.randf_range(
			dir_offset[i] - BULLET_DIR_RANGE,
			dir_offset[i] + BULLET_DIR_RANGE
		)
		
		GlobalPool.bullet_linear_spawned.emit(BULLET, spawners[i].global_transform,
			adjusted_speed, 0, 0, 0,
			0, 1.0, 0, deg_to_rad(dir)
		)




func _on_BulletDull_bullet_deactivate():
	single_deactivate.emit()
	target.queue_free()
	self.queue_free()
