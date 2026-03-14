extends Node2D

var color:Color
var weight:int
var duration:float
var delay:float


var id:int



func _ready() -> void:
	self.modulate.a = 0.0
	self.scale = Vector2.ZERO
	
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.tween_property(self, "modulate:a", 1.0,                  0.8)
	SelfTween.tween_property(self, "scale",      Vector2.ONE,          0.8)
	SelfTween.tween_property(self, "rotation",   self.rotation + TAU , 0.8)
	await SelfTween.finished
	
	%Laser.id = id
	
	%Laser.activate(
		color, weight,
		duration, delay
	)




func _on_Laser_laser_activated() -> void:
	%Sound.play()


func _on_Laser_laser_deactivated() -> void:
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.tween_property(self, "modulate:a", 0,                   0.8)
	SelfTween.tween_property(self, "scale",      Vector2.ZERO,        0.8)
	SelfTween.tween_property(self, "rotation",   self.rotation - TAU, 0.8)
	await SelfTween.finished
	
	%BulletDull.deactivate()


func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
