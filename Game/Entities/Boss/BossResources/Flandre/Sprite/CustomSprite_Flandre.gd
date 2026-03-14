extends CustomSprite_Boss

var idle:String = "_DefaultIdle"
var left:String = "_DefaultLeft"
var right:String = "_DefaultRight"

const PARTICLES := preload("res://Game/Entities/Boss/BossResources/Remilia/Sprite/Particles_Transform.tres")




func _ready():
	self.play(idle)
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
			queued_animation = ""
			self.play(left)
		elif state == STATE.RIGHT:
			queued_animation = left
			self.play_backwards(right)
		state = STATE.LEFT
	
	elif direction == DIRECTION.RIGHT and state != STATE.RIGHT:
		if state == STATE.IDLE:
			queued_animation = ""
			self.play(right)
		elif state == STATE.LEFT:
			queued_animation = right
			self.play_backwards(left)
		state = STATE.RIGHT
	
	elif direction == DIRECTION.IDLE and state != STATE.IDLE:
		if state == STATE.LEFT:
			queued_animation = idle
			self.play_backwards(left)
		elif state == STATE.RIGHT:
			queued_animation = idle
			self.play_backwards(right)
		state = STATE.IDLE
	
	prev_position = global_position




func set_sprite(sprite_frames:SpriteFrames, sprite_offset:Vector2):
	self.sprite_frames = sprite_frames
	self.offset = sprite_offset
	
	%InvincibilitySprite.sprite_frames = sprite_frames
	%InvincibilitySprite.hide()


func play_custom_animation(custom_animation:String):
	state = STATE.CUSTOM
	self.custom_animation = custom_animation
	self.queued_animation = custom_animation
	self.play(custom_animation + "_Transition")


func play_return_animation():
	state = STATE.IDLE
	if custom_animation != "":
		self.queued_animation = idle
		self.play(custom_animation + "_TransitionBack")
	else:
		print("Animation Error")
	
	custom_animation = ""


func play_default() -> void:
	state = STATE.IDLE
	self.custom_animation = ""
	self.queued_animation = ""
	
	self.play(idle)


func special_function(name:String="", args:Array=[]):
	if name == "Idle_Transition":
		play_transition_animation()
	if name == "Invincibility_Sprite_On":
		play_invincibility_on()
	if name == "Invincibility_Sprite_Off":
		play_invincibility_off()
	
	if name == "change_base_color":
		change_base_color(args[0])




func play_transition_animation():
	idle = "_SpearIdle"
	left = "_SpearLeft"
	right = "_SpearRight"
	
	self.play("IdleTransition")
	self.queued_animation = idle


func play_invincibility_on():
	%InvincibilitySprite.show()
	%InvincibilitySprite.play("Bat")
	material.set_shader_parameter("hide", true)
	
	GlobalStage.request_add_object.emit(
		PARTICLES.create_particle(global_position)
	)


func play_invincibility_off():
	%InvincibilitySprite.hide()
	material.set_shader_parameter("hide", false)
	
	GlobalStage.request_add_object.emit(
		PARTICLES.create_particle(global_position)
	)


func change_base_color(color:Color):
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("base_modifier", 0.2)
	material.set_shader_parameter("colorize", true)




func _on_CustomSprite_animation_finished():
	if queued_animation != "":
		self.play(queued_animation)
		queued_animation = ""


func _on_FlashTimer_timeout():
	material.set_shader_parameter("flash_modifier", 0)
