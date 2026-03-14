extends RowData
class_name RowData_Column

@export var columns:Array[ColumnData]

var size:int = 0




func _init(columns:Array[ColumnData]=[]):
	self.columns = columns
	self.size = columns.size()




func get_column(index:int=0):
	return columns[index % columns.size()]
