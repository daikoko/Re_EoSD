extends Node2D

var speed:float
var direction:Vector2
var rotation_speed:float




func _ready() -> void:
	self.modulate.a = 0
	var SelfTween = self.create_tween()
	SelfTween.tween_property(self, "modulate:a", 1.0, 0.8)


func _process(delta:float) -> void:
	self.position += direction * speed * delta
	self.rotation += deg_to_rad(rotation_speed) * delta




func _on_Collider_collider_entered(_other, other_identity) -> void:
	if other_identity == "PlayerGraze":
			GlobalPlayer.player_graze.emit()
	elif other_identity == "PlayerHitbox" and %BulletDull.active:
		GlobalPlayer.player_hit.emit()
		if !%BulletDull.hit_immunity:
			%BulletDull.deactivate()


func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
