extends Node2D

var duration:float




func _ready() -> void:
	var ShadowTween = self.create_tween()
	ShadowTween.tween_property(self, "modulate:a", 0, duration)
	
	await ShadowTween.finished
	
	queue_free()




func build(image:Texture2D, duration:float, modulate:Color) -> void:
	%Sprite.texture = image
	self.duration = duration
	self.modulate = modulate
