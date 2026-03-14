extends ColumnData
class_name ColumnData_Laser

@export var lasers:Array[LaserData]

var size:int = 0




func _init(lasers:Array[LaserData]=[]):
	self.lasers = lasers
	self.size = lasers.size()




func get_laser(index:int=0):
	return lasers[index % lasers.size()]
