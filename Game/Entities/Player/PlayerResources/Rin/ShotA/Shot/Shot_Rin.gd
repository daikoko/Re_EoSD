extends Node2D

@export var rotation_multiplier:int

var rotation_speed:float
const ROTATION_SPEED       := 120.0
const ROTATION_SPEED_FOCUS := 180.0

var level:int
var base_levels:Dictionary
var focus_levels:Dictionary

var focusing:bool = false

var shots:Array
var shots_active:Array

var ShotTween:Tween




func _ready() -> void:
	rotation_speed = ROTATION_SPEED


func _process(delta:float) -> void:
	%Holder.rotation += deg_to_rad(rotation_speed) * rotation_multiplier * delta




func set_levels(
		shot_list:Array,
		base_levels:Dictionary,
		focus_levels:Dictionary
	) -> void:
	
	for shot in shot_list:
		%Holder.add_child(shot)
	
	self.shots = shot_list
	self.base_levels = base_levels
	self.focus_levels = focus_levels


func change_level(level:int) -> void:
	self.level = level
	update()


func focus() -> void:
	self.focusing = true
	rotation_speed = ROTATION_SPEED_FOCUS
	
	update()


func unfocus() -> void:
	self.focusing = false
	rotation_speed = ROTATION_SPEED
	
	update()


func get_active_shots() -> Array:
	var total_shots_active = []
	for shot in shots_active:
		total_shots_active.append_array(shot.get_shots())
	
	return total_shots_active




func update() -> void:
	shots_active.clear()
	
	var shot_dictionary:Dictionary
	if not focusing:
		shot_dictionary = base_levels
	else:
		shot_dictionary = focus_levels
	
	if shots.size() == 0: return
	
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
