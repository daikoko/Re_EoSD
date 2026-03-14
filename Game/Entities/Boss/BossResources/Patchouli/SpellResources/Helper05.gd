extends Node2D

const HELPER_06 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper06.tscn")

var RNG:RandomNumberGenerator




func _process(_delta:float) -> void:
	if GlobalStage.is_current_stage_clear():
		queue_free()




func spawn(amount:int) -> void:
	await GlobalStage.create_timer_short(self, 0.4).timeout
	
	%Line.hide()
	
	var step = 1.0 / amount
	for i in amount:
		var shot = HELPER_06.instantiate()
		
		shot.RNG = RNG
		shot.transform = %Guide.global_transform
		GlobalStage.request_add_object.emit(shot)
		
		%Guide.progress_ratio += step
		await get_tree().process_frame
	
	queue_free()




func _on_Shooter_shooter_disabled() -> void:
	queue_free()
