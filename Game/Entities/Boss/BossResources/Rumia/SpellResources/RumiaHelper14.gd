extends Node2D

const SHAPE_TEMPLATE := preload("res://Game/Objects/Shooters/Shooter/ShapeTemplate.tscn")
const BULLET_DULL := preload("res://Game/Objects/Bullets/BulletScripts/BulletDull.tscn")
const BULLET_DATA := preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeMagenta.tres")

const TIME_LINE   := 0.2
const TIME_TRAVEL := 0.8
const TIME_WAIT   := 0.2

const ARROW_SIZE := 6
const ARROW_LENGTH := 160
const ARROW_WIDTH := 120

const LAYOUT_SPAWNER_COUNT_01 := 48
const LAYOUT_SPAWNER_COUNT_02 := 28
const TWEEN_TIME := 3.6

var RNG:RandomNumberGenerator
var LineTween:Tween
var Template:Node2D

var TweenShooter_01:Shooter_Tween
var Bullets_01:Array[RowData_Bullet]

var TweenShooter_02:Shooter_Tween
var Bullets_02:Array[RowData_Bullet]

@export_group("Shooter")
@export var distance_01:Curve
@export var distance_02:Curve

var mute:bool
var left:bool
var right:bool




func _ready() -> void:
	%Line.width = 0
	%Line.default_color = Color(1, 0, 0, 0)
	
	TweenShooter_01 = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(LAYOUT_SPAWNER_COUNT_01)
	)
	TweenShooter_01.RNG = RNG
	Bullets_01 = [
		RowData_Bullet.new([
			GlobalShooter.KNIFE_MAGENTA
		])
	]
	%Holder.add_child(TweenShooter_01)
	
	TweenShooter_02 = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(LAYOUT_SPAWNER_COUNT_02)
	)
	TweenShooter_02.RNG = RNG
	Bullets_02 = [
		RowData_Bullet.new([
			GlobalShooter.KNIFE_RED
		])
	]
	%Holder.add_child(TweenShooter_02)
	
	start()




func start() -> void:
	%ShadowHandler.effect_start()
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line, "width", 60.0, TIME_LINE)
	LineTween.tween_property(%Line, "default_color:a", 0.2, TIME_LINE)
	LineTween.chain().tween_property(%PathFollow, "progress_ratio", 1.0, TIME_TRAVEL)
	LineTween.chain().tween_interval(TIME_WAIT)
	await LineTween.finished
	
	generate_arrow()
	move_arrow()
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line, "default_color:a", 0.0, TIME_LINE)


func generate_arrow():
	var length_step = ARROW_LENGTH / (ARROW_SIZE - 1)
	var width_step  = ARROW_WIDTH / (ARROW_SIZE - 1) 
	
	for i in ARROW_SIZE:
		var width = width_step * i
		
		for j in (i+1):
			if (j != 0 and j != i):
				continue
			var bullet = BULLET_DULL.instantiate()
			bullet.data = BULLET_DATA
			bullet.visibility_immunity = true
			bullet.position = Vector2(
				(length_step * (ARROW_SIZE - 1 - i)),
				- (width / 2) + (width_step * j)
			)
			%Holder.add_child(bullet)


func move_arrow():
	var ArrowTween = create_tween()
	ArrowTween.tween_property(%Holder, "progress_ratio", 1.0, 0.6)
	await  ArrowTween.finished
	
	queue_free()


func shoot() -> void:
	TweenShooter_01.rotation = randf_range(0, TAU)
	TweenShooter_01.fire_round(
		Bullets_01,
		1, 0,
		0, 0,
		TWEEN_TIME, distance_01,
		GlobalShooter.empty_curve()
	)
	
	TweenShooter_02.rotation = randf_range(0, TAU)
	TweenShooter_02.fire_round(
		Bullets_02,
		1, 0,
		0, 0,
		TWEEN_TIME, distance_02,
		GlobalShooter.empty_curve()
	)




func _on_Shooter_freed() -> void:
	%PathFollow.queue_free()
	
	if LineTween:
		LineTween.kill()
	
	LineTween = create_tween().set_parallel()
	LineTween.tween_property(%Line, "width", 0.0, TIME_LINE)
	LineTween.tween_property(%Line, "default_color:a", 0.0, TIME_LINE)
	await LineTween.finished
	
	queue_free()


func _on_Visibility_screen_exited() -> void:
	shoot()
