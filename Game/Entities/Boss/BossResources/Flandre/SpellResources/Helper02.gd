extends Node2D

var lead:bool

var directions:Array
var direction_next_index:int = 0

var speed:float
var distance:float
var distance_max:float




func _ready() -> void:
	change_direction()


func _process(delta:float) -> void:
	self.position += transform.x * speed * delta
	self.distance += speed * delta
	
	if direction_next_index == directions.size(): return
	if distance > distance_max:
		change_direction()




func build(
		lead:bool,
		directions:Array,
		speed:float
	) -> void:
	
	self.lead       = lead
	self.directions = directions
	self.speed      = speed


func change_direction() -> void:
	var instruction:Vector2  = directions[direction_next_index]
	var instruction_rotate   = instruction.x
	var instruction_distance = instruction.y
	
	self.distance      = 0
	self.distance_max  = instruction_distance
	self.rotation     += deg_to_rad(instruction_rotate)
	
	direction_next_index += 1




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
