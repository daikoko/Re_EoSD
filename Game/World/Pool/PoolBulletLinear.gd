extends Node2D

const BULLET := preload("res://Game/Objects/Bullets/BulletScripts/BulletLinear.tscn")

var max_size:int = 0

var bullet_pool:PackedInt32Array = []

var active_pool:PackedByteArray = []
var active_pool_size:int = -1
var next_index:int = 0



func _ready():
	GlobalPool.bullet_linear_spawned.connect(_on_GlobalPool_bullet_linear_spawned)
	GlobalPool.bullet_linear_despawned.connect(_on_GlobalPool_bullet_linear_despawned)




func fill_pool(amount:int) -> void:
	max_size = amount
	for i in amount:
		var bullet = BULLET.instantiate()
		bullet.id = i
		bullet.stagger = i % 2
		bullet.point = (i % 4 == 0)
		bullet_pool.append(i)
		active_pool.append(0)
		active_pool_size += 1
		self.add_child(bullet)




func _on_GlobalPool_bullet_linear_spawned(
		data:BulletData, transform:Transform2D, 
		speed:float, dir:float=0, rot:float=0, rot_speed:float=0,
		delay:float=0, duration:float=0, speed_change:float=0, dir_change:float=0,
		flash_scale:float=2.0, flash_time:float=0.2, immunity_time:float=0.1
	) -> void:
	
	if (active_pool_size == -1): return
	while (active_pool[next_index] == 1):
		next_index = wrapi(next_index + 1, 0, max_size)
	
	var bullet:BulletLinear = self.get_child(bullet_pool[next_index])
	bullet.activate(data, transform,
		speed, dir, rot, rot_speed,
		delay, duration, speed_change, dir_change,
		flash_scale, flash_time, immunity_time)
	
	active_pool[next_index] = 1
	active_pool_size -= 1
	
	Debug.update_linear(1)


func _on_GlobalPool_bullet_linear_despawned(id:int) -> void:
	active_pool[id] = 0
	active_pool_size += 1
	
	Debug.update_linear(-1)
