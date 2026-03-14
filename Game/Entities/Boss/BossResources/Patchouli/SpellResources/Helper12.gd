extends Node2D

const UP_TIME := 0.8
const DOWN_TIME := 0.2

const DOWN_POSITION := Vector2(0, 120)
const UP_POSITION := Vector2(0, -40)

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
const A_LAYOUT_SHOT_RANGE := 60.0
const A_BULLET_SPEED := 200
const A_STACK_COUNT := 3
const A_STACK_SPEED := 40
const A_SHOOTER_ROTATION := -90.0
var primary_layout_spawner_count:int = 3

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
const B_BULLET_SPEED := 240
const B_BULLET_SPEED_RANGE := 60
const B_BULLET_GRAVITY := 2
const B_SHOOTER_ROTATION_RANGE := Vector2(
	-120,
	-60
)
var secondary_fire_count:int = 40

var RNG:RandomNumberGenerator
var PillarTween:Tween




func _ready() -> void:
	%Pillar.position = DOWN_POSITION
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		primary_layout_spawner_count,
		1,
		360, A_LAYOUT_SHOT_RANGE
	)
	A_Shooter.RNG = RNG
	A_Bullets = [
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.MEDIUM_YELLOW])])
	]
	self.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(1)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.SPADE_YELLOW])])
	]
	self.add_child(B_Shooter) 
	
	fire() 




func fire() -> void:
	PillarTween = create_tween()
	PillarTween.tween_property(%Pillar, "position", UP_POSITION, UP_TIME) 
	PillarTween.tween_property(%Pillar, "position", DOWN_POSITION, DOWN_TIME)  
	await PillarTween.finished
	
	A_Shooter.rotation = deg_to_rad(A_SHOOTER_ROTATION)
	A_Shooter.fire_round_stack(
		A_Bullets,
		1, 0,
		A_BULLET_SPEED, 0,
		0, 0,
		A_STACK_COUNT, A_STACK_SPEED
	)     
	
	B_Shooter.rotation_random = true
	B_Shooter.rotation_random_range = Vector2(
		deg_to_rad(B_SHOOTER_ROTATION_RANGE.x),
		deg_to_rad(B_SHOOTER_ROTATION_RANGE.y)
	)
	B_Shooter.fire_round(
		B_Bullets,
		secondary_fire_count, 0,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE,
		0, 0,
		B_BULLET_GRAVITY
	)         
	
	GlobalStage.request_shake.emit(10, 0.4)    
	
	hide()
	await GlobalStage.create_timer_short(self, 0.8).timeout 
	
	queue_free()                                                                                                                                                                                                                          




func _on_BulletDull_bullet_deactivate() -> void:
	if PillarTween:
		PillarTween.kill()
	
	queue_free()
