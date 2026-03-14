extends Node2D

const ITEM := preload("res://Game/Objects/Items/Score/ItemScore.tscn")

var max_size:int = 0

var item_pool:PackedInt32Array = []

var active_pool:PackedByteArray = []
var active_pool_size:int = -1
var next_index:int = 0




func _ready():
	GlobalPool.item_score_spawned.connect(_on_GlobalPool_item_score_spawned)
	GlobalPool.item_score_despawned.connect(_on_GlobalPool_item_score_despawned)


func fill_pool(amount:int) -> void:
	max_size = amount
	for i in amount:
		var item = ITEM.instantiate()
		item.id = i
		item.delay_offset = randf_range(-ItemScore.DELAY_RANGE, ItemScore.DELAY_RANGE)
		item.time_offset = randf_range(-ItemScore.TIME_RANGE, ItemScore.TIME_RANGE)
		item_pool.append(i)
		active_pool.append(0)
		active_pool_size += 1
		self.add_child(item)




func _on_GlobalPool_item_score_spawned(position:Vector2, value:int, mode:int = 0) -> void:
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		return
	
	var c = 0
	if (active_pool_size == -1): return
	while (active_pool[next_index] == 1):
		next_index = wrapi(next_index + 1, 0, max_size)
		c += 1
		if c > 10:
			print("Score Warning:", c)
	
	var item:ItemScore = self.get_child(item_pool[next_index])
	item.activate(position, value, mode)
	
	active_pool[next_index] = 1
	active_pool_size -= 1


func _on_GlobalPool_item_score_despawned(id:int) -> void:
	active_pool[id] = 0
	active_pool_size += 1
