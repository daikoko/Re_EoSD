extends Node2D

const HELPER_18 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper18.tscn")

const TIME_LINE   := 0.2
const TIME_TRAVEL := 0.8
const TIME_WAIT   := 0.2

var LineTween:Tween
var RNG:RandomNumberGenerator




func _ready() -> void:
	%Line01.width = 0
	%Line01.default_color = Color(1, 0, 0, 0)
	%Line02.width = 0
	%Line02.default_color = Color(1, 0, 0, 0)
	
	start()




func start() -> void:
	%ShadowHandler01.effect_start()
	%ShadowHandler02.effect_start()
	%ShadowHandler03.effect_start()
	%ShadowHandler04.effect_start()
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line01, "width", 60.0, TIME_LINE)
	LineTween.tween_property(%Line01, "default_color:a", 0.2, TIME_LINE)
	LineTween.tween_property(%Line02, "width", 60.0, TIME_LINE)
	LineTween.tween_property(%Line02, "default_color:a", 0.2, TIME_LINE)
	LineTween.chain().tween_property(%PathFollow01, "progress_ratio", 1.0, TIME_TRAVEL)
	LineTween.tween_property(%PathFollow02, "progress_ratio", 1.0, TIME_TRAVEL)
	LineTween.tween_property(%PathFollow03, "progress_ratio", 1.0, TIME_TRAVEL)
	LineTween.tween_property(%PathFollow04, "progress_ratio", 1.0, TIME_TRAVEL)
	LineTween.chain().tween_interval(TIME_WAIT)
	await LineTween.finished
	
	if not GlobalStage.is_current_stage_clear():
		
		var bullet01 = HELPER_18.instantiate()
		bullet01.position = %Path01.global_position
		bullet01.rotation = %Path01.global_rotation
		bullet01.RNG = RNG
		GlobalStage.request_add_object.emit(bullet01)
		bullet01.mute = true
		
		var bullet02 = HELPER_18.instantiate()
		bullet02.position = %Path02.global_position
		bullet02.rotation = %Path02.global_rotation
		bullet02.RNG = RNG
		GlobalStage.request_add_object.emit(bullet02)
		bullet02.mute = true
		
		var bullet03 = HELPER_18.instantiate()
		bullet03.position = %Path03.global_position
		bullet03.rotation = %Path03.global_rotation
		bullet03.RNG = RNG
		GlobalStage.request_add_object.emit(bullet03)
		
		var bullet04 = HELPER_18.instantiate()
		bullet04.position = %Path04.global_position
		bullet04.rotation = %Path04.global_rotation
		bullet04.RNG = RNG
		GlobalStage.request_add_object.emit(bullet04)
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line01, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line01, "default_color:a", 0.0, TIME_LINE)
	LineTween.tween_property(%Line02, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line02, "default_color:a", 0.0, TIME_LINE)
	await LineTween.finished
	
	queue_free()




func _on_Shooter_freed() -> void:
	%PathFollow01.queue_free()
	%PathFollow02.queue_free()
	%PathFollow03.queue_free()
	%PathFollow04.queue_free()
	
	if LineTween:
		LineTween.kill()
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line01, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line01, "default_color:a", 0.0, TIME_LINE)
	LineTween.tween_property(%Line02, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line02, "default_color:a", 0.0, TIME_LINE)
	await LineTween.finished
	
	queue_free()
