extends Node2D

const DISTANCE := 160.0
const ROTATION_SPEED := 60.0
const BULLET_SPEED := 180.0

var shooters:Array = []
var bullets:Array[RowData_Column]

var RNG:RandomNumberGenerator
var first:bool = false

signal shooter_finished




func _ready() -> void:
	bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_MAGENTA
			])
		])
	]
	
	%Sprite01.modulate.a = 0
	%Sprite02.modulate.a = 0


func _process(delta: float) -> void:
	%Rotater01.rotation += deg_to_rad(ROTATION_SPEED) * delta
	%Rotater02.rotation -= deg_to_rad(ROTATION_SPEED) * delta




func build(shooter_count) -> void:
	var angle = deg_to_rad(90.0)
	var step =  deg_to_rad(360.0 / shooter_count)
	
	for i in shooter_count:
		var first_shooter = GlobalShooter.create_basic_shooter(1)
		first_shooter.position = Vector2.RIGHT.rotated(angle) * DISTANCE
		first_shooter.rotation = angle
		first_shooter.rotation_speed = deg_to_rad(RNG.randf_range(80, 120))
		first_shooter.RNG = RNG
		if i == 0: first_shooter.mute = false
		else:      first_shooter.mute = true
		
		shooters.append(first_shooter)
		%Rotater01.add_child(first_shooter)
		
		var second_shooter = GlobalShooter.create_basic_shooter(1)
		second_shooter.position = Vector2.RIGHT.rotated(angle) * DISTANCE
		second_shooter.rotation = angle
		second_shooter.rotation_speed = -deg_to_rad(RNG.randf_range(80, 120))
		second_shooter.RNG = RNG
		if i == 0: second_shooter.mute = false
		else:      second_shooter.mute = true
		
		shooters.append(second_shooter)
		%Rotater02.add_child(second_shooter)
		
		angle += step


func fire(
		fire_count:int,
		fire_duration:float
	) -> void:
	
	if first == false:
		first = true
		
		var SpriteTween = create_tween().set_parallel()
		SpriteTween.tween_property(%Sprite01, "modulate:a", 1.0, 1.0)
		SpriteTween.tween_property(%Sprite02, "modulate:a", 1.0, 1.0)
	
	for shooter in shooters:
		shooter.fire_round(
			bullets,
			fire_count, fire_duration,
			BULLET_SPEED
		)
	await shooters[0].finished_round
	
	shooter_finished.emit()


func disable():
	queue_free()
