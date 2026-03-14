extends Node2D

const BULLET := preload("res://Game/Objects/Bullets/BulletScripts/BulletTween.tscn")

var max_size:int = 0

var bullet_pool:PackedInt32Array = []

var active_pool:PackedByteArray = []
var active_pool_size:int = -1
var next_index:int = 0




func _ready():
	GlobalPool.bullet_tween_spawned.connect(_on_GlobalPool_bullet_tween_spawned)
	GlobalPool.bullet_tween_despawned.connect(_on_GlobalPool_bullet_tween_despawned)




func fill_pool(amount:int) -> void:
	max_size = amount
	for i in amount:
		var bullet = BULLET.instantiate()
		bullet.id = i
		bullet.stagger = i % 2
		bullet.point = (i % 2 == 0)
		bullet_pool.append(i)
		active_pool.append(0)
		active_pool_size += 1
		self.add_child(bullet)




func _on_GlobalPool_bullet_tween_spawned(
		data:BulletData, transform:Transform2D,
		tween_origin:Vector2, tween_offset:float, tween_ratio:float, tween_rotation_start:float, 
		tween_time:float, tween_distance:Curve, tween_rotation:Curve, tween_reverse:float,
		bullet_direct:bool, bullet_rotation_start:float, bullet_rotation:float,
		release_speed:float, release_angle:float, release_aim:bool,
		flash_scale:float, flash_time:float, immunity_time:float
	) -> void:
	
	if (active_pool_size == -1): return
	while (active_pool[next_index] == 1):
		next_index = wrapi(next_index + 1, 0, max_size)
	
	var bullet:BulletTween = self.get_child(bullet_pool[next_index])
	bullet.activate(data, transform,
		tween_origin, tween_offset, tween_ratio, tween_rotation_start,
		tween_time, tween_distance, tween_rotation, tween_reverse,
		bullet_direct, bullet_rotation_start, bullet_rotation,
		release_speed, release_angle, release_aim,
		flash_scale, flash_time, immunity_time)
	
	active_pool[next_index] = 1
	active_pool_size -= 1
	
	Debug.update_tween(1)


func _on_GlobalPool_bullet_tween_despawned(id:int) -> void:
	active_pool[id] = 0
	active_pool_size += 1
	
	Debug.update_tween(-1)
