extends Node2D

var color:Color
var weight:int
var duration:float




func _ready() -> void:
	%Laser.activate(
		color,
		weight,
		duration
	)




func build(
		color:Color,
		weight:int,
		duration:float
	):
	
	self.color = color
	self.weight = weight
	self.duration = duration




func _on_Laser_laser_deactivated() -> void:
	queue_free()
