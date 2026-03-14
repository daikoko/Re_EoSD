extends Node2D

const TIME := 1.6

var started:bool = false
var clear:bool = false
var disabled:bool = false




func _ready() -> void:
	%Helper08.scale = Vector3.ONE * 0
	%Collider.scale = Vector2.ONE * 0


func _process(_delta:float) -> void:
	if (
		(GlobalStage.is_current_stage_clear() == true) or
		(GlobalStage.is_current_player_bomb() == true)
	):
		clear = true
	
	if (
		(clear == true) and 
		(started == true) and 
		(GlobalStage.is_current_stage_clear() == false) and
		(GlobalStage.is_current_player_bomb() == false)
	):
		clear = false
		spawn()




func start():
	started = true
	spawn()


func reset():
	var ScaleTween = create_tween().set_parallel(true)
	ScaleTween.tween_property(%Helper08, "scale", Vector3.ZERO, TIME * 0.4)
	ScaleTween.tween_property(%Collider, "scale", Vector2.ZERO, TIME * 0.4)
	await ScaleTween.finished
	
	for child in %Holder.get_children():
		child.queue_free()
	
	clear = true


func spawn() -> void:
	if disabled:
		return
	
	var shot_list = %Helper08.spawn()
	
	for shot in shot_list:
		shot.connect("cleared", _on_Shot_cleared)
		self.add_child(shot)
	
	var ScaleTween = create_tween().set_parallel(true)
	ScaleTween.tween_property(%Helper08, "scale", Vector3.ONE, TIME)
	ScaleTween.tween_property(%Collider, "scale", Vector2.ONE, TIME)


func disable() -> void:
	disabled = true




func _on_Shot_cleared():
	reset()
