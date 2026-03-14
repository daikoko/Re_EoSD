extends Node2D

var level:int
var base_levels:Dictionary
var focus_levels:Dictionary

var focusing:bool = false

var shots:Array
var shots_active:Array

var ShotTween:Tween




func set_levels(
		shot_list:Array,
		base_levels:Dictionary,
		focus_levels:Dictionary
	) -> void:
	
	for shot in shot_list:
		self.add_child(shot)
	
	self.shots = shot_list
	self.base_levels = base_levels
	self.focus_levels = focus_levels


func change_level(level:int) -> void:
	self.level = level
	update()


func focus() -> void:
	self.focusing = true
	update()


func unfocus() -> void:
	self.focusing = false
	update()


func get_active_shots() -> Array:
	return shots_active




func update() -> void:
	shots_active.clear()
	
	var shot_dictionary:Dictionary
	if not focusing:
		shot_dictionary = base_levels
	else:
		shot_dictionary = focus_levels
	
	set_shot_tween()
	for shot in shots:
		var shot_transform = shot_dictionary[level][shot]["transform"]
		var shot_activated = shot_dictionary[level][shot]["activated"]
		ShotTween.tween_property(shot, "transform", shot_transform, 0.2)
		
		if shot_activated:
			ShotTween.tween_property(shot, "modulate:a", 1.0, 0.2)
			shots_active.append(shot)
		else:
			ShotTween.tween_property(shot, "modulate:a", 0, 0.2)


func set_shot_tween() -> void:
	if ShotTween:
		ShotTween.kill()
	
	ShotTween = create_tween().set_parallel()
