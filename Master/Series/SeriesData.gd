extends Resource
class_name SeriesData
## Contains data for a series

@export var stages:Array[StageData]




func _init(stages:Array[StageData]=[]):
	self.stages = stages




func get_stage_data(index:int) -> StageData:
	if index >= stages.size():
		print("SeriesData Error: Out of Bounds in Series")
		print("Index: ", index)
		print("Level Size: ", stages.size())
		return null
	else:
		return stages[index]
