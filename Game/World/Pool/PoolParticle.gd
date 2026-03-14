extends Node2D

const PARTICLE := preload("res://Game/Objects/Bullets/BulletScripts/ParticleBullet.tscn")

var max_size:int = 0

var particle_pool:PackedInt32Array = []

var active_pool:PackedByteArray = []
var active_pool_size:int = -1
var next_index:int = 0




func _ready():
	GlobalPool.particle_clear_spawned.connect(_on_GlobalPool_particle_clear_spawned)
	GlobalPool.particle_bomb_spawned.connect(_on_GlobalPool_particle_bomb_spawned)
	GlobalPool.particle_despawned.connect(_on_GlobalPool_particle_despawned)




func fill_pool(amount:int) -> void:
	max_size = amount
	for i in amount:
		var particle = PARTICLE.instantiate()
		particle.id = i
		particle_pool.append(i)
		active_pool.append(0)
		active_pool_size += 1
		self.add_child(particle)




func _on_GlobalPool_particle_clear_spawned(position:Vector2) -> void:
	if (active_pool_size == -1): return
	while (active_pool[next_index] == 1):
		next_index = wrapi(next_index + 1, 0, max_size)
	
	var particle = self.get_child(particle_pool[next_index])
	particle.activate_clear(position)
	
	active_pool[next_index] = 1
	active_pool_size -= 1


func _on_GlobalPool_particle_bomb_spawned(position:Vector2, color:Color) -> void:
	if (active_pool_size == -1): return
	while (active_pool[next_index] == 1):
		next_index = wrapi(next_index + 1, 0, max_size)
	
	var particle = self.get_child(particle_pool[next_index])
	particle.activate_bomb(position, color)
	
	active_pool[next_index] = 1
	active_pool_size -= 1


func _on_GlobalPool_particle_despawned(id:int) -> void:
	active_pool[id] = 0
	active_pool_size += 1
