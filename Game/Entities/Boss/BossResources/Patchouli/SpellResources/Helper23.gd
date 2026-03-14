extends Node2D

const START_TIME := 0.8
const POSITION := Vector2(280, -20)

var MainShooterA:Shooter_Basic
var MainShooterB:Shooter_Basic
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
		layout_spawner_count:int
	):
	
	MainShooterA = GlobalShooter.create_basic_shooter(layout_spawner_count)
	MainShooterB = GlobalShooter.create_basic_shooter(layout_spawner_count)
	Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_GREEN
			])
		])
	]
	
	%Sprite.add_child(MainShooterA)
	%Sprite.add_child(MainShooterB)


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
	
	if disabled: return
	
	MainShooterA.rotation_speed =  deg_to_rad(shooter_rotation_speed)
	MainShooterB.rotation_speed = -deg_to_rad(shooter_rotation_speed)
	
	MainShooterA.fire_round(
		Bullets,
		fire_count, fire_duration,
		bullet_speed
	)
	MainShooterB.fire_round(
		Bullets,
		fire_count, fire_duration,
		bullet_speed
	)


func disable():
	disabled = true
	
	MainShooterA.disable()
	MainShooterB.disable()
	
	var SpriteTween = self.create_tween()
	SpriteTween.tween_property(%Sprite, "modulate:a", 0, 0.4)
