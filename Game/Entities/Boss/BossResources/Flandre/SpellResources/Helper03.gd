extends Node2D

enum FRUIT {
	BOMB,
	APPLE,
	BANANA,
	GRAPE
}

var direction:int = 1

var RNG:RandomNumberGenerator
var disabled:bool

const HELPER_04    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper04.tscn")
const FRUIT_BOMB   := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_FlandreFruitBomb.tres")
const FRUIT_APPLE  := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_FlandreFruitApple.tres")
const FRUIT_BANANA := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_FlandreFruitBanana.tres")
const FRUIT_GRAPE  := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_FlandreFruitGrape.tres")

const HEALTH_BOMB  := 280




func fire(
		health_min:int, health_max:int,
		speed_min:float, speed_max:float,
		rotation_min:float, rotation_max:float,
		time_min:float, time_max:float
	) -> void:
	
	if disabled: return
	
	var template:BulletData
	var health:int
	var spawner:int
	var bullet:BulletData
	var bomb:bool
	var fruit:int = RNG.randi_range(0, 3)
	match fruit:
		FRUIT.BOMB:
			template = FRUIT_BOMB
			health =   HEALTH_BOMB
			spawner =  6
			bullet =   GlobalShooter.SPADE_YELLOW
			bomb     = true
		FRUIT.APPLE:
			template = FRUIT_APPLE
			health =   RNG.randf_range(health_min, health_max)
			spawner =  12
			bullet =   GlobalShooter.SPADE_RED
		FRUIT.BANANA:
			template = FRUIT_BANANA
			health =   RNG.randf_range(health_min, health_max)
			spawner =  12
			bullet =   GlobalShooter.SPADE_RED
		FRUIT.GRAPE:
			template = FRUIT_GRAPE
			health =   RNG.randf_range(health_min, health_max)
			spawner =  12
			bullet =   GlobalShooter.SPADE_RED
	
	var dropper = HELPER_04.instantiate()
	dropper.build(
		template,
		health,
		RNG.randf_range(speed_min, speed_max),
		RNG.randf_range(0, TAU),
		RNG.randf_range(rotation_min, rotation_max) * (PI / 180) * direction,
		RNG.randf_range(time_min, time_max),
		spawner,
		bullet,
		bomb
	)
	dropper.position = Vector2(
		RNG.randf_range(40, 640),
		-120
	)
	dropper.rotation = RNG.randf_range(0, TAU)
	
	direction *= -1
	GlobalStage.request_add_object.emit(dropper)


func disable() -> void:
	disabled = true
