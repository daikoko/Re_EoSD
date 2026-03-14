extends Timer
class_name ShortTimer

var disabled:bool = false




func disable() -> void:
	disabled = true
	stop()


func check_start() -> void:
	if disabled:
		return
	else:
		self.start()




func _on_Self_timeout() -> void:
	queue_free()
