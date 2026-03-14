extends RowData
class_name RowData_Bullet

@export var bullets:Array[BulletData]

var size:int = 0




func _init(bullets:Array[BulletData]=[]):
	self.bullets = bullets
	self.size = bullets.size()




func get_bullet(index:int=0):
	return bullets[index % bullets.size()]
