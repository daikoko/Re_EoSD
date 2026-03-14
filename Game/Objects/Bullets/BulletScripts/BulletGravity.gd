extends Sprite2D
class_name BulletGravity

const VALUE := 1200

var query:PhysicsShapeQueryParameters2D
var space:PhysicsDirectSpaceState2D

var id:int
var stagger:int
var point:bool
var active:bool = false

var time:float
var immunity_time:float

var color:Color
var shape:Shape2D

var speed:float
var rot:float
var rot_speed:float

var gravity:float

var direction:Vector2
var velocity:Vector2

var FlashTween:Tween
var SpeedTween:Tween




func _ready():
	query = PhysicsShapeQueryParameters2D.new()
	space = get_world_2d().direct_space_state
	
	query.collide_with_areas = true
	query.collision_mask = 1
	
	active = false
	visible = false
	set_process(false)


func _process(delta):
	if !%Visibility.is_on_screen() and time > immunity_time:
		deactivate()
		return
	
	time += delta
	position += velocity * delta
	velocity.y += gravity * delta
	
	rot += rot_speed * delta
	if rot_speed == 0:
		rotation = velocity.angle() + rot
	else:
		rotation = rot
	
	if stagger != 0:
		stagger -= 1
		return
	else:
		stagger = 1
	
	if GlobalStage.is_current_stage_clear_plain():
		deactivate()
		return
	elif GlobalStage.is_current_stage_clear():
		if point:
			GlobalPool.particle_clear_spawned.emit(position)
		deactivate()
		return
	elif GlobalStage.is_current_stage_bomb():
		if point:
			GlobalPool.item_point_spawned.emit(position, true)
			GlobalPool.item_score_spawned.emit(position, VALUE)
			GlobalPool.particle_bomb_spawned.emit(position, color)
		deactivate()
		return
	
	query.transform = global_transform
	var result = space.intersect_shape(query, 1)
	if result:
		var object:Collider = result[0]["collider"]
		var identity:String = object.identity
		
		if identity == "PlayerGraze":
			GlobalPlayer.player_graze.emit()
			query.set_exclude([result[0]["collider"]])
		elif identity == "Bomb":
			if point:
				GlobalPool.item_point_spawned.emit(position, true)
				GlobalPool.item_score_spawned.emit(position, VALUE)
				GlobalPool.particle_bomb_spawned.emit(position, color)
			deactivate()
		elif identity == "PlayerHitbox" and active:
			GlobalPlayer.player_hit.emit()
			deactivate()




func activate(data:BulletData, transform:Transform2D, 
	speed:float, rot:float, rot_speed:float,
	gravity:float,
	flash_scale:float, flash_time:float, immunity_time:float) -> void:
	
	self.texture =     data.texture
	self.color =       data.color
	self.shape =       data.shape
	$Visibility.rect = data.visibility
	
	self.transform = transform
	query.set_shape(shape)
	query.set_exclude([])
	query.transform = transform
	
	self.speed = speed
	self.rot = rot
	self.rot_speed = rot_speed
	
	self.gravity = gravity
	
	self.direction = Vector2.RIGHT.rotated(self.rotation)
	self.velocity = direction * speed
	
	self.time = 0
	self.immunity_time = immunity_time
	
	if flash_time == 0:
		scale = Vector2.ONE
		material.set_shader_parameter("flash_color", color)
		material.set_shader_parameter("flash_modifier", 0)
	else:
		scale = Vector2.ONE * flash_scale
		material.set_shader_parameter("flash_color", color)
		material.set_shader_parameter("flash_modifier", 1.0)
	
	FlashTween = create_tween().set_parallel(true)
	FlashTween.tween_property(self, "scale", Vector2.ONE, flash_time)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 0.0, flash_time)
	FlashTween.finished.connect(_on_FlashTween_finished)
	
	active = true
	visible = true
	set_process(true)




func deactivate() -> void:
	GlobalPool.bullet_gravity_despawned.emit(id)
	
	if FlashTween:
		FlashTween.kill()
	if SpeedTween:
		SpeedTween.kill()
	
	active = false
	visible = false
	set_process(false)




func _on_FlashTween_finished():
	active = true
