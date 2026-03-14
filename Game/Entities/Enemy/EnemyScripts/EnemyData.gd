extends Resource
class_name EnemyData

@export var id:String = ""
@export var description:String = ""
@export var spawn_seed:int = -1 
@export var amount:int = 1
@export var time:float = 1

@export_group("Enemy")
@export var sprite:EnemySpriteData
@export var death:DeathData
@export var health:float = 1
@export var speed:float = 350.0
@export var speed_range:float = 0.0

@export_group("Shooters")
@export var start_time:float = 0.1
@export var shooters:Array[EnemyShooter]
@export var death_shooters:Array[EnemyShooter]

@export_group("Retreat")
@export var retreat:bool = false
@export var retreat_time:float = 5.0
@export var retreat_speed:float = 600.0

@export_group("Modifier")
@export var amount_override:Dictionary = {
	"Easy":    -1,
	"Normal":  -1,
	"Hard":    -1,
	"Lunatic": -1
}
@export var health_override:Dictionary = {
	"Easy":    -1,
	"Normal":  -1,
	"Hard":    -1,
	"Lunatic": -1
}

var amount_true:int
var health_true:int

var RNG:RandomNumberGenerator




func start() -> void:
	var difficulty_key = GlobalSettings.get_difficulty_key_string(
		GlobalStage.current_difficulty
	)
	
	if amount_override[difficulty_key] != -1:
		amount_true = amount_override[difficulty_key]
	else:
		amount_true = roundi(amount * GlobalStage.get_spawn_modifier("amount"))
	
	if health_override[difficulty_key] != -1:
		health_true = health_override[difficulty_key]
	else:
		health_true = roundi(health * GlobalStage.get_spawn_modifier("health"))
	
	RNG = RandomNumberGenerator.new()
	if spawn_seed == -1:
		RNG.randomize()
	else:
		RNG.seed = spawn_seed
	
	var interval:float = time / amount_true
	initialize(amount_true)
	
	var SpawnTimer = Timer.new()
	if interval > 0:
		GlobalStage.request_add_object.emit(SpawnTimer)
		SpawnTimer.wait_time = interval
		SpawnTimer.start()
	
	for i in amount_true:
		new_enemy(i)
		if interval > 0:
			await SpawnTimer.timeout
	
	SpawnTimer.queue_free()




func new_enemy(count:int) -> void:
	var enemy:Node2D = get_enemy()
	enemy.sprite = sprite.get_sprite()
	enemy.hitbox = sprite.get_hitbox()
	enemy.health = health
	enemy.speed = speed + RNG.randf_range(
		-speed_range, 
		speed_range
	)
	
	enemy.retreat = retreat
	enemy.retreat_time = retreat_time
	
	for shooter in shooters:
		var RNG_copy = RandomNumberGenerator.new()
		RNG_copy.seed = RNG.randi()
		var copy = shooter.copy()
		copy.deactivated.connect(enemy._on_Shooter_deactivated)
		copy.RNG = RNG_copy
		copy.set_shooter(enemy)
		enemy.shooters.append(copy)
		enemy.active_shooters += 1
	
	for shooter in death_shooters:
		var RNG_copy = RandomNumberGenerator.new()
		RNG_copy.seed = RNG.randi()
		var copy = shooter.copy()
		copy.deactivated.connect(enemy._on_DeathShooter_deactivated)
		copy.RNG = RNG_copy
		copy.set_shooter(enemy)
		enemy.death_shooters.append(copy)
		enemy.active_death_shooters += 1
	
	if death:
		enemy.death = death
	else:
		enemy.death = DeathData.new()
	
	add_enemy(enemy, count)


func initialize(_amount:int) -> void:
	pass


func get_enemy() -> Node2D:
	return Node2D.new()


func add_enemy(_enemy:Node2D, _count:int) -> void:
	pass
