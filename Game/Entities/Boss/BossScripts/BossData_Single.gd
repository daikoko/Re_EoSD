extends BossData
class_name BossData_Single

@export var single:Array[BossEvent]




func _init(
	single:Array[BossEvent]=[]
	):
	
	self.single = single




func get_events() -> Array:
	var buffer = single
	var duplicate = []
	
	for event in buffer:
		duplicate.append(event.duplicate())
	
	return duplicate
