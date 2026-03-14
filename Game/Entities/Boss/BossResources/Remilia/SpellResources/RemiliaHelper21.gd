extends Node2D

var MainShooter:Shooter_Arrow
var LeftShooter:Shooter_Arrow
var RightShooter:Shooter_Arrow

const CENTRAL_ARROW_SIZE := 6
const CENTRAL_ARROW_LENGTH := 180.0
const CENTRAL_ARROW_WIDTH := 180.0
const CENTRAL_ARROW_DISPLACEMENT := 800.0
const CENTRAL_ARROW_FILL := true
const CENTRAL_FIRE_COUNT := 9
const CENTRAL_BULLET_SPEED := 900
const CENTRAL_BULLET_SPEED_ROW := -80

const SIDE_ARROW_SIZE := 5
const SIDE_ARROW_LENGTH := 120.0
const SIDE_ARROW_WIDTH := 400.0
const SIDE_ARROW_DISPLACEMENT := 800.0
const SIDE_ARROW_FILL := false
const SIDE_FIRE_COUNT := 7
const SIDE_BULLET_SPEED := 700
const SIDE_BULLET_SPEED_ROW := -80


var bullet_data:Array[RowData_Column]


func _ready():
	%Main.modulate.a = 0
	
	MainShooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(1),
		CENTRAL_ARROW_SIZE, CENTRAL_ARROW_LENGTH, CENTRAL_ARROW_WIDTH, 
		CENTRAL_ARROW_DISPLACEMENT,
		CENTRAL_ARROW_FILL
	)
	%Line01.add_child(MainShooter)
	
	LeftShooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(1),
		SIDE_ARROW_SIZE, SIDE_ARROW_LENGTH, SIDE_ARROW_WIDTH, 
		SIDE_ARROW_DISPLACEMENT,
		SIDE_ARROW_FILL
	)
	%Line02.add_child(LeftShooter)
	
	RightShooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(1),
		SIDE_ARROW_SIZE, SIDE_ARROW_LENGTH, SIDE_ARROW_WIDTH, 
		SIDE_ARROW_DISPLACEMENT,
		SIDE_ARROW_FILL
	)
	%Line03.add_child(RightShooter)
	
	bullet_data = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]




func fire():
	%FireTimer.wait_time = 1.6
	%FireTimer.start()
	
	var LineTween = self.create_tween()
	
	LineTween.tween_interval(1.2)
	
	LineTween.tween_property(%Main, "modulate:a", 1.0, 0.2)
	LineTween.tween_interval(0.4)
	
	LineTween.tween_property(%Main, "modulate:a", 0.0, 0.2)


func disable():
	queue_free()




func _on_FireTimer_timeout() -> void:
	MainShooter.fire_round(
		bullet_data,
		CENTRAL_FIRE_COUNT, 0,
		CENTRAL_BULLET_SPEED, 0,
		CENTRAL_BULLET_SPEED_ROW
	)
	LeftShooter.fire_round(
		bullet_data,
		SIDE_FIRE_COUNT, 0,
		SIDE_BULLET_SPEED, 0,
		SIDE_BULLET_SPEED_ROW
	)
	RightShooter.fire_round(
		bullet_data,
		SIDE_FIRE_COUNT, 0,
		SIDE_BULLET_SPEED, 0,
		SIDE_BULLET_SPEED_ROW
	)
