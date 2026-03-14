extends Sprite2D
class_name ItemLife

var query:PhysicsShapeQueryParameters2D
var space:PhysicsDirectSpaceState2D

enum STATE {
	FALL,
	TARGET
}

const TIME := 0.5
const ROT_SPEED := 60.0
const FALL_SPEED := 200.0
const TARGET_SPEED := 400.0
const TARGET_STEER_FORCE := 100.0

var state:int
var target:Node2D
var velocity:Vector2
var delay:bool = true


func _ready():
	query = PhysicsShapeQueryParameters2D.new()
	space = get_world_2d().direct_space_state
	
	query.collide_with_areas = true
	query.collision_mask = 2
	query.set_shape(CircleShape2D.new())
	
	self.state = STATE.FALL
	self.target = null
	self.velocity = Vector2.DOWN * FALL_SPEED


func _process(delta):
	if delay:
		delay = false
	elif %Visibility.is_on_screen() == false:
		queue_free()
	
	if GlobalStage.is_current_stage_clear_plain():
		queue_free()
		return
	elif GlobalStage.is_current_stage_clear() and state == STATE.TARGET:
		state = STATE.FALL
		velocity = Vector2.DOWN * FALL_SPEED
		target = null
	
	if state == STATE.TARGET:
		var target_vector := target.global_position - self.position
		var steer_vector := target_vector - velocity
		steer_vector.limit_length(TARGET_STEER_FORCE)
		velocity += steer_vector
		velocity = velocity.normalized() * TARGET_SPEED
	
	position += velocity * delta
	rotation_degrees += ROT_SPEED * delta
	
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
			GlobalPlayer.life_get.emit()
			queue_free()


func _on_Visibility_screen_exited() -> void:
	pass # Replace with function body.
