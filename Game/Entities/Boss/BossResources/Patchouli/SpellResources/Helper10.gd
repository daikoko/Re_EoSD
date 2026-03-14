extends Node2D

var MainShooter:Shooter_Basic
var Bullets:Array[RowData_Column]

const BULLET_SPEED := 240.0
const BULLET_SPEED_RANGE := 40.0
const SHOOTER_ROTATION := 45

var RNG:RandomNumberGenerator
var disabled:bool = false




func _ready() -> void:
	MainShooter = GlobalShooter.create_basic_shooter(1)
	MainShooter.RNG = RNG
	%Guide.add_child(MainShooter)
	
	Bullets = [
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.SPADE_BLUE])]),
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.SPADE_BLUE])]),
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.SPADE_CYAN])]),
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.SPADE_CYAN])]),
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.SPADE_CYAN])])
	]




func fire() -> void:
	if disabled:
		return
	
	for i in Bullets.size():
		%Guide.progress_ratio = RNG.randf_range(0, 1)
		
		MainShooter.global_rotation = deg_to_rad(SHOOTER_ROTATION)
		MainShooter.fire_row(
			Bullets[i],
			BULLET_SPEED, BULLET_SPEED_RANGE
		)


func disable() -> void:
	disabled = true
