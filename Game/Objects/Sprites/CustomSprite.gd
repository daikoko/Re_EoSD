extends AnimatedSprite2D
class_name CustomSprite

enum STATE {
	IDLE,
	LEFT,
	RIGHT,
	CUSTOM,
}

enum DIRECTION {
	LEFT,
	RIGHT,
	IDLE
}

const SENSITIVITY := 0.1

var state:int
var custom_animation:String
var queued_animation:String = ""
var prev_position:Vector2




func _ready():
	self.play("_Idle")
	state = STATE.IDLE
	prev_position = global_position


func _process(_delta):
	var difference = global_position.x - prev_position.x
	var direction = DIRECTION.IDLE
	if difference < -SENSITIVITY:
		direction = DIRECTION.LEFT
	elif difference > SENSITIVITY:
		direction = DIRECTION.RIGHT
	
	if direction == DIRECTION.LEFT and state != STATE.LEFT:
		if state == STATE.IDLE:
			queued_animation = ""
			self.play("_Left")
		elif state == STATE.RIGHT:
			queued_animation = "_Left"
			self.play_backwards("_Right")
		state = STATE.LEFT
		
	elif direction == DIRECTION.RIGHT and state != STATE.RIGHT:
		if state == STATE.IDLE:
			queued_animation = ""
			self.play("_Right")
		elif state == STATE.LEFT:
			queued_animation = "_Right"
			self.play_backwards("_Left")
		state = STATE.RIGHT
		
	elif direction == DIRECTION.IDLE and state != STATE.IDLE:
		if state == STATE.LEFT:
			queued_animation = "_Idle"
			self.play_backwards("_Left")
		elif state == STATE.RIGHT:
			queued_animation = "_Idle"
			self.play_backwards("_Right")
		state = STATE.IDLE
	
	prev_position = global_position


func flash(intensity:float = 0.5, color:Color = Color(1, 1, 1, 1)):
	material.set_shader_parameter("flash_color",    color)
	material.set_shader_parameter("flash_modifier", intensity)
	%FlashTimer.start()


func disable_flash():
	self.material = null




func _on_CustomSprite_animation_finished():
	if queued_animation != "":
		self.play(queued_animation)
		queued_animation = ""


func _on_FlashTimer_timeout():
	material.set_shader_parameter("flash_modifier", 0)
