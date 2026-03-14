extends Node2D

var delay:float




func _ready():
	%Enemy.disable()
	self.modulate.a = 0.0
	
	var SelfTween = self.create_tween()
	SelfTween.tween_interval(                       delay)
	SelfTween.tween_property(self, "modulate:a", 0.8, 0.2)
	await SelfTween.finished
	
	%Enemy.enable()
	
	SelfTween = self.create_tween()
	SelfTween.tween_interval(                       0.4)
	SelfTween.tween_property(self, "modulate:a", 0, 0.4)
	await SelfTween.finished
	
	queue_free()




func _on_Enemy_collider_entered(_other, other_identity) -> void:
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()


func _on_Tile_exiting():
	queue_free()
