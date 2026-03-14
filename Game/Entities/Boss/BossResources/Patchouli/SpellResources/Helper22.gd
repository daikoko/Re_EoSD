extends Node2D

const START_TIME := 0.8
const POSITION := Vector2(140, -80)

var MainShooter:Shooter_Arrow
var Bullets:Array[RowData_Column]

var RNG:RandomNumberGenerator
var disabled:bool

var time:float




func _ready() -> void:
	%Sprite.modulate.a = 0
	%Sprite.scale = Vector2.ONE


func _process(delta:float) -> void:
	time += delta




func build(
		layout_spawner_count:int,
		arrow_size:int,
		arrow_length:float,
		arrow_width:float,
		arrow_displacement:float
	):
	
	MainShooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(layout_spawner_count),
		arrow_size, arrow_length, arrow_width, 
		arrow_displacement,
		false
	)
	Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_YELLOW
			])
		])
	]
	%Sprite.add_child(MainShooter)


func start():
	var SpriteTween = self.create_tween().set_parallel(true)
	SpriteTween.tween_property(%Sprite, "scale",      Vector2.ONE * 0.8, START_TIME)
	SpriteTween.tween_property(%Sprite, "modulate:a", 1.0,               START_TIME)
	SpriteTween.tween_property(%Sprite, "position",   POSITION,          START_TIME)


func fire(
		fire_count:int, fire_duration:float,
		bullet_speed:float,
		shooter_rotation_speed:float
	):
	
	if disabled:return
	
	MainShooter.rotation_speed = deg_to_rad(shooter_rotation_speed)
	MainShooter.fire_round(
		Bullets, 
		fire_count, fire_duration,
		bullet_speed,
	)


func disable():
	disabled = true
	
	var SpriteTween = self.create_tween()
	SpriteTween.tween_property(%Sprite, "modulate:a", 0, 0.4)
