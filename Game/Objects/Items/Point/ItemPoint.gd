extends Sprite2D
class_name ItemPoint

var query:PhysicsShapeQueryParameters2D
var space:PhysicsDirectSpaceState2D

enum STATE {
	LAUNCH,
	FALL,
	TARGET
}

const INITIAL_VALUE := 1000.0
const DECAY := 200.0

const LAUNCH_TIME := 0.2
const LAUNCH_SPEED := 200.0

const FALL_GRAVITY := 200.0
const FALL_SPEED_INITIAL := 350.0
const FALL_SPEED_MAX := 200.0

const TARGET_STEER_FORCE := 100
const TARGET_SPEED := 400

var id:int = 0
var stagger:int
var immunity:bool

var value:float = 0

var state:int
var target: Node2D
var velocity:Vector2
var rand_offset:float
var rand_angle:float
var time:float
var delay:bool


func _ready():
	query = PhysicsShapeQueryParameters2D.new()
	space = get_world_2d().direct_space_state
	
	query.collide_with_areas = true
	query.collision_mask = 2
	query.set_shape(CircleShape2D.new())
	
	set_process(false)
	visible = false


func _process(delta):
	if delay:
		delay = false
	elif %Visibility.is_on_screen() == false and immunity == false:
		deactivate()
	
	if GlobalStage.is_current_stage_clear_plain():
		deactivate()
		return
	elif GlobalStage.is_current_stage_clear() and state == STATE.TARGET:
		state = STATE.FALL
		velocity = Vector2.DOWN * FALL_SPEED_INITIAL
		target = null
	
	if state == STATE.LAUNCH:
		position += velocity * delta
		time -= delta
		if time < 0:
			state = STATE.FALL
			velocity = Vector2.DOWN * FALL_SPEED_INITIAL
		return
		
	elif state == STATE.FALL:
		position += velocity * delta
		velocity.y += FALL_GRAVITY * delta
		velocity = velocity.limit_length(FALL_SPEED_MAX)
		value = clamp(value - (DECAY * delta), 0, INITIAL_VALUE)
		
	elif state == STATE.TARGET:
		var target_vector := target.global_position - self.position
		var steer_vector := target_vector - velocity
		steer_vector.limit_length(TARGET_STEER_FORCE)
		velocity += steer_vector
		velocity = velocity.normalized() * TARGET_SPEED
		position += velocity * delta
	
	if stagger != 0:
		stagger -= 1
		return
	stagger = 1
	
	query.transform = global_transform
	var result = space.intersect_shape(query, 1)
	if result:
		var collider:Collider = result[0]["collider"]
		var identity = collider.identity
		
		if identity == "PlayerCollection" and state == STATE.FALL:
			state = STATE.TARGET
			target = result[0]["collider"]
			velocity = (target.global_position - self.position).normalized() * TARGET_SPEED
			query.set_exclude([result[0]["collider"]])
		elif identity == "PlayerItem" and state == STATE.TARGET:
			GlobalPlayer.point_get.emit(ceili(value))
			deactivate()


func activate(position:Vector2, from_bullet:bool) -> void:
	self.position = position
	self.modulate.a = 0.4
	self.value = INITIAL_VALUE
	self.target = null
	if from_bullet:
		self.state = STATE.FALL
		self.velocity = Vector2.UP * LAUNCH_SPEED
	else:
		self.state = STATE.LAUNCH
		self.velocity = Vector2.RIGHT.rotated(rand_angle) * (LAUNCH_SPEED+rand_offset)
		self.time = LAUNCH_TIME
	
	query.set_exclude([])
	
	immunity = true
	set_process(true)
	visible = true
	delay = true
	
	await self.create_tween().tween_interval(4.0).finished
	
	immunity = false


func deactivate() -> void:
	GlobalPool.item_point_despawned.emit(id)
	
	set_process(false)
	visible = false




func _on_Visibility_screen_exited():
	if is_processing() and immunity == false:
		deactivate()
