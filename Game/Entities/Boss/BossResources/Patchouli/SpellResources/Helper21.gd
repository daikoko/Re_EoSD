extends Node2D

const START_TIME := 0.8
const POSITION := Vector2(0, -120)

const A_LAYOUT_DISTANCE := 60.0

var A1_Shooter:Shooter_Laser
var A2_Shooter:Shooter_Laser
var A_lasers:RowData_Column

var RNG:RandomNumberGenerator
var disabled:bool




func _ready() -> void:
	%Sprite.modulate.a = 0
	%Sprite.scale = Vector2.ONE




func build(A_layout_spawner_count:int):
	A1_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			A_layout_spawner_count, 
			1, 360, 360, 
			A_LAYOUT_DISTANCE)
	)
	A2_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			A_layout_spawner_count, 
			1, 360, 360, 
			A_LAYOUT_DISTANCE)
	)
	A_lasers = RowData_Column.new([
		ColumnData_Laser.new([
			LaserData.new(10.0, LaserData.COLOR.RED)
		])
	])
	
	%Sprite.add_child(A1_Shooter)
	%Sprite.add_child(A2_Shooter)


func start():
	
	var SpriteTween = self.create_tween().set_parallel(true)
	SpriteTween.tween_property(%Sprite, "scale",      Vector2.ONE * 0.8, START_TIME)
	SpriteTween.tween_property(%Sprite, "modulate:a", 1.0,               START_TIME)
	SpriteTween.tween_property(%Sprite, "position",   POSITION,          START_TIME)


func fire(
		A_laser_duration:float,
		A_shooter_rotation_speed:float,
		A_shooter_delay:float
	):
	
	A1_Shooter.rotation_speed =  deg_to_rad(A_shooter_rotation_speed)
	A2_Shooter.rotation_speed = -deg_to_rad(A_shooter_rotation_speed)
	
	while not disabled:
		A1_Shooter.fire_round(
			A_lasers,
			A_laser_duration
		)
		await self.create_tween().tween_interval(A_shooter_delay).finished
		
		A2_Shooter.fire_round(
			A_lasers,
			A_laser_duration
		)
		await self.create_tween().tween_interval(A_shooter_delay).finished


func disable():
	disabled = true
	
	A1_Shooter.disable()
	A2_Shooter.disable()
	
	var SpriteTween = self.create_tween()
	SpriteTween.tween_property(%Sprite, "modulate:a", 0, 0.4)
