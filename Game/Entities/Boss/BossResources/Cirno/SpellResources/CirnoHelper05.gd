extends Node2D

const SNOWFLAKE_ARM := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper06.tscn")

var disabled:bool = false
var arms:Array = []

signal finished_spawning



func set_snowflake(arm_count:int, rng:RandomNumberGenerator) -> void:
	for i in arm_count:
		var arm = SNOWFLAKE_ARM.instantiate()
		self.add_child(arm)
		arms.append(arm)
		arm.rng = rng
		arm.rotation = i * (TAU / arm_count)
		
		if i != 0:
			arm.mute = true


func spawn_bullets(
		body_count:int, body_speed:float,
		edge_count:int, edge_speed:float
	) -> void:
	
	if disabled:
		return
	
	for arm in arms:
		arm.spawn_bullets(body_count, body_speed, edge_count, edge_speed)
	
	%SpawningTimer.wait_time = 1.2
	%SpawningTimer.start()


func disable() -> void:
	disabled = true




func _on_SpawningTimer_timeout():
	finished_spawning.emit()
