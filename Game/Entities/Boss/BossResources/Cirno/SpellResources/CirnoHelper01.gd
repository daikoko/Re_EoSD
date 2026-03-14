extends Node2D

const CIRNO_DROP := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper02.tscn")

const A_BOUND_RIGHT  := 620
const A_BOUND_LEFT   := 30
const A_BOUND_TOP    := 80
const A_BOUND_BOTTOM := 120

var RNG:RandomNumberGenerator

var disabled:bool = false




func drop(
		layout_spawner_count:int, 
		bullet_speed:float,
		stack_count:int, stack_speed:float
	) -> void:
	
	if disabled:
		return 
	
	var CirnoDrop = CIRNO_DROP.instantiate()
	CirnoDrop.position = Vector2(
		RNG.randf_range(A_BOUND_LEFT, A_BOUND_RIGHT),
		RNG.randf_range(A_BOUND_TOP, A_BOUND_BOTTOM)
	)
	
	CirnoDrop.start_angle = RNG.randf_range(0, TAU)
	CirnoDrop.spawner_count = layout_spawner_count
	CirnoDrop.bullet_speed = bullet_speed
	CirnoDrop.stack_count = stack_count
	CirnoDrop.stack_speed = stack_speed
	
	CirnoDrop.max_speed = RNG.randf_range(230, 270)
	CirnoDrop.time = RNG.randf_range(1.2, 2.4)
	
	%Sound.play()
	GlobalStage.request_add_object.emit(CirnoDrop)


func disable() -> void:
	disabled = true
