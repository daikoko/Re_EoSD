extends Path2D
class_name ShapeTemplate

const POINTER := preload("res://Game/Objects/Shooters/Shooter/Pointer.tscn")

enum SHAPE {
	CIRCLE,
	SQUARE,
	TRIANGLE,
	STAR
}

const SHAPE_DICT = {
	SHAPE.CIRCLE:   preload("res://Game/Objects/Shooters/ShooterShape/ShapeCircle.tres"),
	SHAPE.SQUARE:   preload("res://Game/Objects/Shooters/ShooterShape/ShapeSquare.tres"),
	SHAPE.TRIANGLE: preload("res://Game/Objects/Shooters/ShooterShape/ShapeTriangle.tres"),
	SHAPE.STAR:     preload("res://Game/Objects/Shooters/ShooterShape/ShapeStar.tres")
}



func load_template(shape:int) -> void:
	self.curve = SHAPE_DICT[shape]


func generate_transforms(
	amount:int, 
	distance:float, scale:Vector2) -> Array:
	
	var array:Array = []
	var interval:float = 1.0 / amount
	for count in amount:
		%Pointer.progress_ratio = interval * count
		var pos:Vector2 = %Pointer.position * scale
		var rot:float = pos.angle()
		var ratio = pos.length() / 100
		pos = Vector2.RIGHT.rotated(rot) * (distance * ratio)
		
		var spawner = POINTER.instantiate()
		spawner.position = pos
		spawner.rotation = rot
		spawner.distance = distance * ratio
		spawner.ratio = ratio
		array.append(spawner)
	
	return array


func generate_arrow(
		arrow_size:int, arrow_length:float, arrow_width:float,
		displacement:float,
		fill:bool
	) -> Array:
	
	var map:Array = []
	var base = displacement + arrow_length
	
	var length_step = 0
	var width_step = 0
	if arrow_size != 0:
		length_step = arrow_length / (arrow_size - 1)
		width_step = arrow_width / (arrow_size - 1) 
	
	for i in arrow_size:
		var width = width_step * i
		
		for j in (i+1):
			if !fill and (j != 0 and j != i):
				continue
			
			var pointer = POINTER.instantiate()
			var pos = Vector2(
				displacement + (length_step * (arrow_size - 1 - i)),
				- (width / 2) + (width_step * j)
			)
			pointer.rotation = pos.angle()
			pointer.ratio = pos.length() / base
			map.append(pointer)
	
	return map
