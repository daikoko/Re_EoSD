extends Node2D

const LIFE := preload("res://Game/Objects/Items/Life/ItemLife.tscn")
const BOMB := preload("res://Game/Objects/Items/Bomb/ItemBomb.tscn")

@export var bullet_stagger:int = 1
@export var item_drop:int = 4

@export_group("Pool")
@export_range(0,2000,100) var bullet_gravity:int
@export_range(0,2000,100) var bullet_linear:int
@export_range(0,2000,100) var bullet_tween:int
@export_range(0,2000,100) var bullet_sine:int




func _ready():
	GlobalPool.item_life_spawned.connect(_on_GlobalPool_life_spawned)
	GlobalPool.item_bomb_spawned.connect(_on_GlobalPool_bomb_spawned)




func set_pools() -> void:
	var total_bullets:int = bullet_gravity + bullet_linear
	var items:int = int(total_bullets / item_drop)
	
	%PoolBulletGravity.fill_pool(bullet_gravity)
	%PoolBulletLinear.fill_pool(bullet_linear)
	%PoolBulletSine.fill_pool(bullet_sine)
	%PoolBulletTween.fill_pool(bullet_tween)
	%PoolItemPoint.fill_pool(items)
	%PoolItemPower.fill_pool(items)
	%PoolItemScore.fill_pool(items)
	%PoolParticle.fill_pool(items)




func _on_GlobalPool_life_spawned(position):
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		return
	
	var life = LIFE.instantiate()
	life.position = position
	 
	GlobalStage.request_add_object.emit(life)


func _on_GlobalPool_bomb_spawned(position):
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		return
	
	var bomb = BOMB.instantiate()
	bomb.position = position
	
	GlobalStage.request_add_object.emit(bomb)
