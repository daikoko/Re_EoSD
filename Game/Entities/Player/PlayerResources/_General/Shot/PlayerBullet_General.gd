extends Sprite2D

var query:PhysicsShapeQueryParameters2D
var space:PhysicsDirectSpaceState2D

var shape:Shape2D
var speed:float = 0
var damage:float = 0
var decay:float

var pierce:bool

var immunity = true




func _ready():
	query = PhysicsShapeQueryParameters2D.new()
	space = get_world_2d().direct_space_state
	
	query.collide_with_areas = true
	query.collision_mask = 4
	query.set_shape(shape)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.5, 0.2)
	
	var timer = GlobalStage.create_timer(self, 0.6)
	timer.start()
	await timer.timeout
	immunity = false


func _process(delta):
	if immunity:
		pass
	elif !%Visibility.is_on_screen():
		queue_free()
	
	position += transform.x * speed * delta
	query.transform = global_transform
	damage = clamp(damage - (decay * delta), 0, 1000)
	
	var result = space.intersect_shape(query, 1)
	if result:
		var collider:Collider = result[0]["collider"]
		var identity = collider.identity
		
		if identity == "Enemy":
			collider.hit(ceili(damage))
			# if pierce:return
			queue_free()
		
		elif identity == "Obstacle":
			queue_free()




func set_bullet(
	bullet:BulletData, 
	transform:Transform2D, speed:float, 
	damage:float, decay:float) -> void:
	
	self.texture = bullet.texture
	self.shape = bullet.shape
	self.modulate.a = 0
	%Visibility.rect = bullet.visibility
	
	self.transform = transform
	self.speed = speed
	self.damage = damage
	self.decay = decay
