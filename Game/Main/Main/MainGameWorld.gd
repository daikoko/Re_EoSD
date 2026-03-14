extends Node2D

const SHAKE_DAMP_EASE := 1.4

var shake_amplitude:float
var shake_time:float
var shake_time_remaining:float
var shake_hold:bool = false

var RNG:RandomNumberGenerator




func _ready():
	GlobalStage.request_shake.connect(_on_GlobalStage_request_shake)
	GlobalStage.request_shake_release.connect(_on_GlobalStage_request_shake_release)
	GlobalStage.request_slow.connect(_on_GlobalStage_request_slow)
	GlobalStage.request_slow_release.connect(_on_GlobalStage_request_slow_release)
	GlobalStage.request_stop.connect(_on_GlobalStage_request_stop)
	GlobalStage.request_stop_reload.connect(_on_GlobalStage_request_stop_reload)
	GlobalStage.request_stop_release.connect(_on_GlobalStage_request_stop_release)
	
	%Blur.material.set_shader_parameter("lod", 0)


func _process(delta):
	if !shake_hold:
		shake_time_remaining -= delta
	if shake_time_remaining <= 0:
		%GameCamera.offset = GlobalStage.VIEWPORT_SIZE / 2
		set_process(false)
		return
	
	var dampening = ease((shake_time_remaining / shake_time), SHAKE_DAMP_EASE)
	%GameCamera.offset = (GlobalStage.VIEWPORT_SIZE / 2) + Vector2(
		GlobalStage.random_range(-shake_amplitude, shake_amplitude, RNG) * dampening,
		GlobalStage.random_range(-shake_amplitude, shake_amplitude, RNG) * dampening
	)




func pause(pause_music:bool) -> void:
	await get_tree().process_frame
	
	%Blur.material.set_shader_parameter("lod", 3)
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	if pause_music:
		GlobalStage.request_music_pause.emit()


func resume() -> void:
	%Blur.material.set_shader_parameter("lod", 0)
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	GlobalStage.request_music_resume.emit()


func shake(amplitude:float, duration:float, hold:bool=false):
	%GameCamera.offset = GlobalStage.VIEWPORT_SIZE / 2
	shake_amplitude = amplitude
	shake_time = duration
	shake_time_remaining = duration
	shake_hold = hold
	set_process(true)


func release_shake():
	shake_hold = false


func slow():
	Engine.time_scale = 0.5


func release_slow():
	Engine.time_scale = 1.0


func stop():
	%Grayscale.show()
	%Grayscale.texture = get_viewport_texture()
	self.process_mode = Node.PROCESS_MODE_DISABLED


func reload_stop():
	%Grayscale.texture = get_viewport_texture()


func release_stop():
	%Grayscale.hide()
	self.process_mode = Node.PROCESS_MODE_INHERIT


func get_viewport_texture() -> Texture2D:
	var texture:Image = %GameWindow.get_texture().get_image()
	var image:ImageTexture = ImageTexture.create_from_image(texture)
	
	return image




func _on_GlobalStage_request_shake(amplitude, duration, hold=false):
	shake(amplitude, duration, hold)


func _on_GlobalStage_request_shake_release():
	release_shake()


func _on_GlobalStage_request_slow():
	slow()


func _on_GlobalStage_request_slow_release():
	release_slow()


func _on_GlobalStage_request_stop():
	stop()


func _on_GlobalStage_request_stop_reload():
	reload_stop()


func _on_GlobalStage_request_stop_release():
	release_stop()
