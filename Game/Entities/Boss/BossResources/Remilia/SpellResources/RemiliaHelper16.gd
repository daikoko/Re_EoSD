extends Node2D

const HELPER_18 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper18.tscn")

const TIME_LINE   := 0.2
const TIME_TRAVEL := 0.8
const TIME_WAIT   := 0.2

var LineTween:Tween
var RNG:RandomNumberGenerator

var mute:bool




func _ready() -> void:
	%Line.width = 0
	%Line.default_color = Color(1, 0, 0, 0)
	
	start()




func start() -> void:
	%ShadowHandler.effect_start()
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line, "width", 60.0, TIME_LINE)
	LineTween.tween_property(%Line, "default_color:a", 0.2, TIME_LINE)
	LineTween.chain().tween_property(%PathFollow, "progress_ratio", 1.0, TIME_TRAVEL)
	LineTween.chain().tween_interval(TIME_WAIT)
	await LineTween.finished
	
	if not GlobalStage.is_current_stage_clear():
		var bullet = HELPER_18.instantiate()
		bullet.position = self.global_position
		bullet.rotation = self.global_rotation
		bullet.mute = mute
		bullet.RNG = RNG
		
		GlobalStage.request_add_object.emit(bullet)
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line, "default_color:a", 0.0, TIME_LINE)
	await LineTween.finished
	
	queue_free()




func _on_Shooter_freed() -> void:
	%PathFollow.queue_free()
	
	if LineTween:
		LineTween.kill()
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line, "default_color:a", 0.0, TIME_LINE)
	await LineTween.finished
	
	queue_free()
