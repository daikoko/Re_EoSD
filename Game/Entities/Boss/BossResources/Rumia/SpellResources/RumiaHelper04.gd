extends Node2D

var ClearTween:Tween
var clear:bool = false




func _process(_delta: float) -> void:
	if (not clear) and (GlobalStage.is_current_player_bomb() or GlobalStage.is_current_stage_clear()):
		clear = true
		
		if ClearTween:
			ClearTween.kill()
		ClearTween = create_tween().set_parallel()
		ClearTween.tween_property(%Spawners, "self_modulate:a", 0.2, 1.0)
		ClearTween.tween_property(%SpritesView, "self_modulate:a", 0.2, 1.0)
	
	if (clear) and (not GlobalStage.is_current_player_bomb() and not GlobalStage.is_current_stage_clear()):
		clear = false
		
		if ClearTween:
			ClearTween.kill()
		ClearTween = create_tween().set_parallel()
		ClearTween.tween_property(%Spawners, "self_modulate:a", 1.0, 1.0)
		ClearTween.tween_property(%SpritesView, "self_modulate:a", 1.0, 1.0)




func add_spawner(spawner:Node2D) -> void:
	%Spawners.add_child(spawner)


func add_sprite(sprite:Node2D) -> void:
	%SpritesView.add_child(sprite)


func _on_Self_tree_exiting() -> void:
	pass # Replace with function body.
