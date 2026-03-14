extends Timer
class_name ObjectTimer

var disabled:bool = false




func disable() -> void:
	disabled = true
	stop()


func check_start() -> void:
	if disabled:
		return
	else:
		self.start()
