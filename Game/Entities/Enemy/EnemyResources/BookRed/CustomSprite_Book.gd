extends CustomSprite
class_name CustomSprite_Book




func _ready():
	self.play("_Idle")
	state = STATE.LEFT
	prev_position = global_position


func _process(_delta):
	var motion = (
		(global_position - prev_position).length_squared() 
		> SENSITIVITY
	)
	
	if (motion != true) and (state == STATE.LEFT):
		state = STATE.CUSTOM
		await self.animation_looped
		
		if state != STATE.CUSTOM:
			return
		
		state = STATE.IDLE
		self.play("_Open")
	
	elif (motion == true) and (state == STATE.IDLE or state == STATE.CUSTOM):
		state = STATE.RIGHT
		self.play("_Close")
		queued_animation = "_Idle"
		
	
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
