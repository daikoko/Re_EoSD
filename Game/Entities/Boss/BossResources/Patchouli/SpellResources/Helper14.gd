extends Node2D

const SPADE_ORANGE := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Bullet_PatchouliSpadeOrange.tres")

@export var distance_curve:Curve
@export var rotation_curve:Curve

var A_Shooter:Shooter_Basic
var A_Bullets:RowData_Column
const A_LAYOUT_SPAWNER_COUNT := 2
const A_LAYOUT_SHOT_RANGE := 40.0
const A_FIRE_TIME := 0.1
const A_BULLET_SPEED := 180
const A_BULLET_SPEED_RANGE := 40
const A_SHOOTER_ROTATION := 180
var A_FireTimer:ObjectTimer

const TIME_MAX:float = 8

var RNG:RandomNumberGenerator
var time:float
var mute:bool




func _ready() -> void:
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_LAYOUT_SPAWNER_COUNT,
		1, 360, A_LAYOUT_SHOT_RANGE
	)
	A_Shooter.RNG = RNG
	A_Shooter.rotation = deg_to_rad(A_SHOOTER_ROTATION)
	A_Shooter.mute = mute
	A_Shooter.flash_scale = 3.0
	A_Shooter.flash_time = 0.2
	A_Bullets = RowData_Column.new([ColumnData_Bullet.new([SPADE_ORANGE])])
	A_FireTimer = GlobalStage.create_timer(
		self,
		A_FIRE_TIME,
		false
	)
	%Guide.add_child(A_Shooter)
	
	fire()


func _process(delta:float) -> void:
	time += delta
	if time > TIME_MAX:
		queue_free()
	
	var distance = distance_curve.sample(time / TIME_MAX)
	var rotation_speed = rotation_curve.sample(time / TIME_MAX)
	
	self.rotation += delta * deg_to_rad(rotation_speed)
	self.position = distance * Vector2.RIGHT.rotated(self.rotation)




func fire() -> void:
	A_FireTimer.start()
	while true:
		A_Shooter.fire_row(
			A_Bullets,
			A_BULLET_SPEED, A_BULLET_SPEED_RANGE
		)
		
		await A_FireTimer.timeout
