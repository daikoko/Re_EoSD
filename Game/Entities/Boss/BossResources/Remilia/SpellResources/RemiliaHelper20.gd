extends Node2D

const BULLET_DATA := preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeRed.tres")
const BULLET_SPEED := 0
const LINEAR_DELAY := 0.4
const LINEAR_DURATION := 2.4
const LINEAR_SPEED_CHANGE := 180

var origin:Vector2
var distance:float
var velocity:float
var acceleration:float

var angle:float
var angle_speed:float
var direction:int

var passed:bool

var mute:bool




func _process(delta:float) -> void:
	position = origin + (Vector2.RIGHT.rotated(angle) * distance)
	distance += velocity * delta
	velocity += acceleration * delta
	angle += angle_speed * delta * direction
	rotation = angle
	
	if (passed == false) and (velocity < 120):
		passed = true
		
		%FireTimer.start()
	
	if distance < 0:
		%BulletDull.visibility_immunity = false
	
	if distance < -200:
		%FireTimer.stop()




func build(
		spawners_count:int,
		rotation:float
	) -> void:
	
	var angle = rotation
	var step = TAU / spawners_count
	for i in spawners_count:
		var spawner = Marker2D.new()
		spawner.position = Vector2.RIGHT.rotated(angle) * 40.0
		spawner.rotation = angle
		
		angle += step
		
		%Main.add_child(spawner)


func activate(
		origin:Vector2,
		distance:float,
		velocity:float,
		acceleration:float,
		angle:float,
		angle_speed:float,
		direction:int,
		fire_time:float
	) -> void:
	
	self.origin = origin
	self.distance = distance
	self.velocity = velocity
	self.acceleration = acceleration
	self.angle = angle
	self.angle_speed = angle_speed
	self.direction = direction
	%FireTimer.wait_time = fire_time
	
	%ShadowHandler.effect_start()




func _on_FireTimer_timeout() -> void:
	for spawner in %Main.get_children():
		GlobalPool.bullet_linear_spawned.emit(
			BULLET_DATA, spawner.global_transform,
			BULLET_SPEED, 0, 0, 0,
			LINEAR_DELAY, 
			LINEAR_DURATION,
			LINEAR_SPEED_CHANGE,
		)
	
	if mute == false:
		%Sound.play()




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
