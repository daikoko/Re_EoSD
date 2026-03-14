extends Resource
class_name BossData

@export var easy:Array[BossEvent]
@export var normal:Array[BossEvent]
@export var hard:Array[BossEvent]
@export var lunatic:Array[BossEvent]




func _init(
	easy:Array[BossEvent]=[],
	normal:Array[BossEvent]=[],
	hard:Array[BossEvent]=[],
	lunatic:Array[BossEvent]=[],):
	
	self.easy =    easy
	self.normal =  normal
	self.hard =    hard
	self.lunatic = lunatic




func get_events() -> Array:
	var buffer = []
	var duplicate = []
	match GlobalStage.current_difficulty:
		GlobalSettings.DIFFICULTY.EASY:
			buffer = easy
		GlobalSettings.DIFFICULTY.NORMAL:
			buffer = normal
		GlobalSettings.DIFFICULTY.HARD:
			buffer = hard
		GlobalSettings.DIFFICULTY.LUNATIC:
			buffer = lunatic
		_:
			buffer = normal
	
	for event in buffer:
		duplicate.append(event.duplicate())
	
	return duplicate
