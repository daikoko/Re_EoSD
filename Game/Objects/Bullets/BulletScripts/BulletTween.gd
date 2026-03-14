extends Sprite2D
class_name BulletTween

const VALUE := 1200

enum STATE {
	TWEENING,
	RELEASED
}
var state:int

var query:PhysicsShapeQueryParameters2D
var space:PhysicsDirectSpaceState2D

var id:int
var stagger:int
var point:bool
var active:bool = false

var color:Color
var shape:Shape2D

var tween_origin:Vector2

var tween_time:float
var tween_offset:float
var tween_ratio:float

var tween_distance_curve:Curve
var tween_rotation_curve:Curve
var tween_reverse:float
var bullet_direct:bool
var bullet_rotation:float

var immunity_time:float
var release_speed:float
var release_angle:float
var release_aim:bool

var current_time:float
var tween_angle:float
var tween_vector:Vector2
var release_velocity:Vector2

var old_position:Vector2

var FlashTween:Tween




func _ready():
	query = PhysicsShapeQueryParameters2D.new()
	space = get_world_2d().direct_space_state
	
	query.collide_with_areas = true
	query.collision_mask = 1
	
	active = false
	visible = false
	set_process(false)


func _process(delta):
	if state == STATE.TWEENING:
		var curve_offset = current_time / tween_time
		var distance = tween_distance_curve.sample(curve_offset) * tween_ratio
		var rotation_speed = deg_to_rad(tween_rotation_curve.sample(curve_offset)) * tween_reverse
		tween_angle += rotation_speed * delta
		tween_vector = Vector2.RIGHT.rotated(tween_angle) * (tween_offset + distance)
		
		old_position = self.position
		self.position = tween_origin + tween_vector
		
		if bullet_direct: self.rotation = old_position.angle_to_point(self.position)
		else: self.rotation += (rotation_speed + bullet_rotation) * delta
		
		if current_time > tween_time:
			state = STATE.RELEASED
			if release_aim:
				release_velocity = GlobalPlayer.direction_to_player(self.position) * release_speed
				self.rotation = release_velocity.angle()
			else:
				release_velocity = Vector2.RIGHT.rotated((release_angle * tween_reverse) + tween_angle) * release_speed
				self.rotation = release_velocity.angle()
	
	elif state == STATE.RELEASED:
		self.position += release_velocity * delta
		
		if !%Visibility.is_on_screen() and current_time > tween_time + immunity_time:
			deactivate()
			return
	
	current_time += delta
	
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
	tween_origin:Vector2, tween_offset:float, tween_ratio:float, tween_rotation_start:float, 
	tween_time:float, tween_distance:Curve, tween_rotation:Curve, tween_reverse:float,
	bullet_direct:bool, bullet_rotation_start:float, bullet_rotation:float,
	release_speed:float, release_angle:float, release_aim:bool,
	flash_scale:float, flash_time:float, immunity_time:float) -> void:
	
	self.texture =     data.texture
	self.color =       data.color
	self.shape =       data.shape
	$Visibility.rect = data.visibility
	
	self.transform = transform
	self.rotation = tween_rotation_start + bullet_rotation_start
	
	self.tween_origin = tween_origin
	self.tween_offset = tween_offset
	self.tween_ratio = tween_ratio
	
	self.tween_time = tween_time
	self.tween_distance_curve = tween_distance
	self.tween_rotation_curve = tween_rotation
	self.tween_offset = tween_offset
	self.tween_ratio = tween_ratio
	self.tween_reverse = tween_reverse
	self.bullet_direct = bullet_direct
	self.bullet_rotation = bullet_rotation
	
	self.release_speed = release_speed
	self.release_angle = release_angle
	self.release_aim = release_aim
	
	current_time = 0
	tween_angle = tween_rotation_start
	state = STATE.TWEENING
	
	query.set_shape(shape)
	query.set_exclude([])
	query.transform = self.transform
	
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
	
	active = false
	visible = true
	set_process(true)




func deactivate() -> void:
	GlobalPool.bullet_tween_despawned.emit(id)
	
	if FlashTween:
		FlashTween.kill()
	
	active = false
	visible = false
	set_process(false)




func _on_FlashTween_finished():
	active = true
