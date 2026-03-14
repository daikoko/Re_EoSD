extends GPUParticles2D




func _ready():
	if one_shot:
		emitting = true
		
		%Timer.wait_time = lifetime
		%Timer.start()




func _on_Timer_timeout():
	queue_free()
