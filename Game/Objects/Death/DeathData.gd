extends Resource
class_name DeathData

@export var particles:ParticleData
@export_range(0,1000,10,"or_greater") var value:int
@export_range(0,20,1,"or_greater") var point:int
@export_range(0,20,1,"or_greater") var power:int
@export var life:bool
@export var bomb:bool
@export var boss:bool




func start(position:Vector2):
	if particles:
		var particle = particles.create_particle(position)
		GlobalStage.request_add_object.emit(particle)
	
	for i in point:
		GlobalPool.item_point_spawned.emit(position, false)
	
	for i in power:
		GlobalPool.item_power_spawned.emit(position)
	
	if life:
		GlobalPool.item_life_spawned.emit(position)
	
	if bomb:
		GlobalPool.item_bomb_spawned.emit(position)
	
	if value > 0:
		if boss == false:
			GlobalPool.item_score_spawned.emit(position, value, 1)
		else:
			GlobalPool.item_score_spawned.emit(position, value, 2)
