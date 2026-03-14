extends Node2D

const TIME := 1.0




func _ready() -> void:
	%Barrier.scale = Vector2.ONE * 2.0
	%Barrier.modulate.a = 0




func start():
	%Afterimage.effect_start()
	
	var BarrierTween = self.create_tween().set_parallel(true)
	BarrierTween.tween_property(%Barrier, "scale",      Vector2.ONE * 0.7, TIME)
	BarrierTween.tween_property(%Barrier, "modulate:a", 1.0,               TIME)
	BarrierTween.tween_property(%Barrier, "rotation",   TAU,               TIME)
	await BarrierTween.finished
	
	%Afterimage.effect_stop()


func disable():
	queue_free()




func _on_Collider_collider_entered(_other, other_identity) -> void:
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()
