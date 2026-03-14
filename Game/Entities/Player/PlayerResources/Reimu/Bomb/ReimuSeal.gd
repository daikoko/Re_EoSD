extends Node2D

enum STATUS_SEAL {
	IDLE,
	FIRE
}

enum STATUS_TARGET {
	IDLE,
	TARGET
}

var status_seal:int = STATUS_SEAL.IDLE
var status_target:int = STATUS_TARGET.IDLE

const DISTANCE_SPEED := 160
const DISTANCE_MAX := 100
const ROTATION_SPEED := 240.0
const RELEASE_TIME := 1.4

var Origin:Node2D
var distance:float
var rotation_offset:float

const STEER_FORCE := 100

var current_scale:float = 1.0
var velocity:Vector2
var target:Node2D

var speed:float = 0
var damage:float = 0




func _ready():
	%Sprite.scale = Vector2.ONE * 0.2
	%ReleaseTimer.wait_time = RELEASE_TIME
	%ReleaseTimer.start()


func _process(delta):
	if status_seal != STATUS_SEAL.IDLE and !%Visibility.is_on_screen():
		queue_free()
	
	if status_seal == STATUS_SEAL.IDLE:
		distance = clamp(distance + (DISTANCE_SPEED * delta), 0, DISTANCE_MAX)
		rotation_offset += deg_to_rad(ROTATION_SPEED * delta)
		position = Origin.global_position + (Vector2.RIGHT.rotated(rotation_offset) * distance)
	elif status_seal == STATUS_SEAL.FIRE:
		position += velocity * delta
	
	if status_target == STATUS_TARGET.IDLE:
		current_scale += 1.0
		%Targeter.scale = Vector2.ONE * current_scale
	elif status_target == STATUS_TARGET.TARGET:
		if !target or !is_instance_valid(target):
			status_target = STATUS_TARGET.IDLE
			target = null
			current_scale = 1.0
			%Targeter.enable()
			return
		var desired = global_position.direction_to(target.global_position) * speed
		var steer = velocity.direction_to(desired) * STEER_FORCE
		velocity = (velocity + steer).normalized() * speed




func set_bullet(transform:Transform2D, damage:float, speed:float, origin:Node2D) -> void:
	self.transform = transform
	self.damage = damage
	self.speed = speed
	
	self.Origin = origin
	self.rotation_offset = rotation




func _on_ReleaseTimer_timeout():
	status_seal = STATUS_SEAL.FIRE
	velocity = (position - Origin.global_position).rotated(deg_to_rad(90)).normalized() * speed
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(%Sprite, "scale", Vector2.ONE, 3.2)


func _on_Targeter_collider_entered(collider, identity):
	if identity == "Enemy":
		status_target = STATUS_TARGET.TARGET
		target = collider
		%Targeter.disable()


func _on_Bomb_collider_entered(collider, identity):
	if identity == "Enemy":
		collider.hit(damage)
		%Sound.play()
		
		set_process(false)
		
		var FreeTween = self.create_tween().set_parallel(true)
		FreeTween.tween_property(%Sprite, "scale", Vector2.ONE * 2, 0.6)
		FreeTween.tween_property(%Sprite, "modulate:a", 0, 0.6)
		await FreeTween.finished
		
		queue_free()
