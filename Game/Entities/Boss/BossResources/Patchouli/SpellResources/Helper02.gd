extends Node2D

const HELPER_03 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper03.tscn")

var RNG:RandomNumberGenerator
var disabled:bool = false

signal shooter_disabled




func fire(layout_spawner_count:float) -> void:
	if disabled:
		return
	
	var shot = HELPER_03.instantiate()
	self.connect("shooter_disabled", shot._on_Shooter_shooter_disabled)
	shot.position = Vector2(
		RNG.randf_range(0, GlobalStage.VIEWPORT_SIZE.x),
		RNG.randf_range(0, GlobalStage.VIEWPORT_SIZE.y - 400)
	)
	GlobalStage.request_add_object.emit(shot)
	
	shot.fire(layout_spawner_count)


func disable() -> void:
	disabled = true
	
	shooter_disabled.emit()
