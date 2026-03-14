extends CustomSprite
class_name CustomSprite_Boss


func _ready():
	self.play("_Idle")
	state = STATE.IDLE
	prev_position = global_position


func _process(_delta):
	if state == STATE.CUSTOM:
		return
	
	var motion = (global_position - prev_position).length_squared() != 0
	var difference = global_position.x - prev_position.x
	
	var direction = DIRECTION.IDLE
	if motion and difference <= 0:
		direction = DIRECTION.LEFT
	elif motion and difference > 0:
		direction = DIRECTION.RIGHT
	
	if direction == DIRECTION.LEFT and state != STATE.LEFT:
		if state == STATE.IDLE:
			self.play("_Left")
		elif state == STATE.RIGHT:
			queued_animation = "_Left"
			self.play_backwards("_Right")
		state = STATE.LEFT
	
	elif direction == DIRECTION.RIGHT and state != STATE.RIGHT:
		if state == STATE.IDLE:
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




func set_sprite(sprite_frames:SpriteFrames, sprite_offset:Vector2):
	self.sprite_frames = sprite_frames
	self.offset = sprite_offset


func play_custom_animation(custom_animation:String):
	state = STATE.CUSTOM
	self.custom_animation = custom_animation
	self.queued_animation = custom_animation
	self.play(custom_animation + "_Transition")


func play_return_animation():
	state = STATE.IDLE
	if custom_animation != "":
		self.queued_animation = "_Idle"
		self.play(custom_animation + "_TransitionBack")
	else:
		print("Animation Error")
	
	custom_animation = ""


func play_default() -> void:
	state = STATE.IDLE
	self.custom_animation = ""
	self.queued_animation = ""
	
	self.play("_Idle")


func special_function(_name:String="", _args:Array=[]):
	pass




func _on_CustomSprite_animation_finished():
	if queued_animation != "":
		self.play(queued_animation)
		queued_animation = ""


func _on_FlashTimer_timeout():
	material.set_shader_parameter("flash_modifier", 0)
