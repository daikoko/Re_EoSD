extends Sprite2D

var speed:float = 0
var rotation_speed:float = 0




func _process(delta: float) -> void:
	self.position.y += speed * delta
	self.rotation += deg_to_rad(rotation_speed) * delta




func _on_Visibility_screen_exited() -> void:
	queue_free()
