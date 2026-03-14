extends Node2D

@export var image:Texture2D
@export var interval:float
@export var duration:float

const SHADOW := preload("res://Game/Objects/Shadow/Shadow.tscn")




func effect_start():
	%Timer.wait_time = interval
	%Timer.start()


func effect_stop():
	%Timer.stop()




func _on_Timer_timeout() -> void:
	var shadow = SHADOW.instantiate()
	shadow.transform = self.global_transform
	shadow.build(
		image,
		duration,
		modulate
	)
	
	GlobalStage.request_add_object.emit(shadow)
