extends Area2D
class_name Collider

@export var identity:String
@export var shape:Shape2D

signal collider_hit(damage:int)
signal collider_entered(other:Collider, other_identity:String)




func _ready():
	if shape != null:
		%Shape.set_deferred("shape", shape)




func set_shape(shape:Shape2D) -> void:
	%Shape.set_deferred("shape", shape)
	self.shape = shape


func change_scale(scale:Vector2) -> void:
	%Shape.set_deferred("scale", scale)


func change_rect_size(size:Vector2) -> void:
	%Shape.shape.set_deferred("size", size)


func enable() -> void:
	%Shape.set_deferred("disabled", false)


func disable() -> void:
	%Shape.set_deferred("disabled", true)


func is_disabled() -> bool:
	return %Shape.disabled


func hit(damage:float) -> void:
	collider_hit.emit(damage)



func _on_Collider_area_entered(other:Collider):
	collider_entered.emit(other, other.identity)
