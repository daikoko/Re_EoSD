extends Node2D

const RANGE_X := Vector2(10, 670)
const RANGE_Y := Vector2(780, 800)

const HELPER_12 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper12.tscn")

var RNG:RandomNumberGenerator
var disabled:bool = false




func fire(
		primary_layout_spwner_count:int,
		secondary_fire_count:int
	) -> void:
	
	if disabled:
		return
	
	if GlobalStage.is_current_stage_clear():
		return
	
	var random_position = Vector2(
		RNG.randf_range(RANGE_X.x, RANGE_X.y),
		RNG.randf_range(RANGE_Y.x, RANGE_Y.y)
	)
	
	var pillar = HELPER_12.instantiate()
	pillar.position = random_position
	pillar.primary_layout_spawner_count = primary_layout_spwner_count
	pillar.secondary_fire_count = secondary_fire_count
	pillar.RNG = RNG
	
	GlobalStage.request_add_object.emit(pillar)




func disable() -> void:
	disabled = true
