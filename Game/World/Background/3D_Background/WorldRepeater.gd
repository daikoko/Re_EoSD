extends Node3D

@export var world_slice:PackedScene
@export var speed_multiplier:float = 1
@export var slice_range:Vector3

@export_group("Extents")
@export var x_extent:Vector2
@export var y_extent:Vector2
@export var z_extent:Vector2

var current_position:Vector3 = Vector3(1000, 1000, 1000)
var id_dict:Dictionary = {}




func check_world_slices():
	id_dict.clear()
	
	for x in range(-x_extent.x, x_extent.y + 1):
		for y in range(-y_extent.x, y_extent.y + 1):
			for z in range(-z_extent.x, z_extent.y + 1):
				var pos = -current_position + Vector3(x, y, z)
				id_dict[pos] = false
	
	for WorldSlice in self.get_children():
		if id_dict.has(WorldSlice.id):
			id_dict[WorldSlice.id] = true
		else:
			WorldSlice.queue_free()
	
	for id in id_dict:
		if id_dict[id] == false:
			var WorldSliceObject = world_slice.instantiate()
			WorldSliceObject.id = id
			WorldSliceObject.position = id * slice_range
			self.add_child(WorldSliceObject)




func _on_World_update_position(movement:Vector3):
	self.position += movement * speed_multiplier
	
	var new_position = (self.position / slice_range).round()
	if new_position != current_position:
		current_position = new_position
		check_world_slices()
