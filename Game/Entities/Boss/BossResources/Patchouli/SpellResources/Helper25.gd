extends Node2D

const START_TIME := 0.8
const POSITION := Vector2(-140, -80)

var MainShooter:Shooter_Basic
var Bullets:Array[RowData_Column] =[]

var direction:int = 1

var RNG:RandomNumberGenerator
var disabled:bool

var time:float




func _ready() -> void:
	%Sprite.modulate.a = 0
	%Sprite.scale = Vector2.ONE


func _process(delta:float) -> void:
	time += delta




func build(layout_spawner_count:int):
	MainShooter = GlobalShooter.create_basic_shooter(layout_spawner_count)
	Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_MAGENTA
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
		spawn_stack_count:int, spawn_stack_speed:float,
		shooter_rotation_speed:float
	):
	
	if disabled:
		pass
	
	MainShooter.rotation = RNG.randf_range(0, TAU)
	MainShooter.rotation_speed = deg_to_rad(shooter_rotation_speed) * direction
	
	MainShooter.fire_round(
		Bullets,
		fire_count, fire_duration,
		bullet_speed, 0,
		0, 0,
		0,
		0, 0,
		spawn_stack_count, spawn_stack_speed
	)
	
	direction *= -1


func disable():
	disabled = true
	
	MainShooter.disable()
	
	var SpriteTween = self.create_tween()
	SpriteTween.tween_property(%Sprite, "modulate:a", 0, 0.4)
