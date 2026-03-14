extends Sprite2D

enum STATUS {
	IDLE,
	TARGET
}

var query:PhysicsShapeQueryParameters2D
var space:PhysicsDirectSpaceState2D

const STEER_FORCE := 120.0

var shape:Shape2D
var speed:float = 0
var damage:float = 0
var decay:float = 0

var status:int = 0
var immunity:bool = true

var current_scale:float = 1.0
var velocity:Vector2

var target:Node2D = null




func _ready():
	query = PhysicsShapeQueryParameters2D.new()
	space = get_world_2d().direct_space_state
	
	query.collide_with_areas = true
	query.collision_mask = 4
	query.set_shape(shape)
	
	velocity = Vector2.RIGHT.rotated(rotation) * speed


func _process(delta):
	if !%Visibility.is_on_screen() and !immunity:
		queue_free()
	
	position += velocity * delta
	rotation = velocity.angle()
	query.transform = global_transform
	damage = clamp(damage - (decay * delta), 0, 1000)
	
	if status == STATUS.IDLE:
		current_scale += 0.8
		%Targeter.scale = Vector2.ONE * current_scale
	
	elif status == STATUS.TARGET:
		if !target or !is_instance_valid(target):
			status = STATUS.IDLE
			target = null
			current_scale = 1.0
			%Targeter.enable()
			return
		
		var desired = global_position.direction_to(target.global_position) * speed
		var steer = velocity.direction_to(desired) * STEER_FORCE
		velocity = (velocity + steer).normalized() * speed
	
	
	var result = space.intersect_shape(query, 1)
	if result:
		var collider:Collider = result[0]["collider"]
		var identity = collider.identity
		
		if identity == "Enemy":
			collider.hit(ceili(damage))
			queue_free()




func set_bullet(
	bullet:BulletData, 
	transform:Transform2D, speed:float, 
	damage:float, decay:float ) -> void:
	
	self.texture = bullet.texture
	self.shape = bullet.shape
	# self.modulate.a = 0
	%Visibility.rect = bullet.visibility
	
	self.transform = transform
	self.speed = speed
	self.damage = damage
	self.decay = decay
	
	self.velocity = Vector2.RIGHT.rotated(transform.get_rotation()) * speed




func _on_Targeter_collider_entered(area, identity):
	if identity == "Enemy":
		status = STATUS.TARGET
		target = area
		%Targeter.disable()


func _on_ImmunityTimer_timeout():
	immunity = false
