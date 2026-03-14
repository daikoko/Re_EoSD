extends Node2D

const TIME := 0.4

const START_SCALE := 0.2 * Vector2.ONE
const START_MODULATE := 0

const END_SCALE := 0.0 * Vector2.ONE
const END_MODULATE := 0.6

const LAYOUT_SHOT_RANGE := 60.0
const FIRE_COUNT := 4
const FIRE_DURATION := 0.4
const BULLET_SPEED := 300.0

var MainShooter:Shooter_Basic
var SpriteTween:Tween

var bullets:Array[RowData_Column]




func _ready() -> void:
	%Sprite.scale = START_SCALE
	%Sprite.modulate.a = START_MODULATE
	
	bullets = [
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.MEDIUM_GREEN])]),
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.BRIGHT_GREEN])]),
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.BRIGHT_GREEN])]),
		RowData_Column.new([ColumnData_Bullet.new([GlobalShooter.BRIGHT_GREEN])]),
	]




func fire(layout_spawner_count:float) -> void:
	%Sound.play()
	
	MainShooter = GlobalShooter.create_basic_shooter(
		layout_spawner_count,
		1, 360, LAYOUT_SHOT_RANGE
	)
	self.add_child(MainShooter)
	
	SpriteTween = create_tween().set_parallel()
	SpriteTween.tween_property(%Sprite, "scale", END_SCALE, TIME)
	SpriteTween.tween_property(%Sprite, "modulate:a", END_MODULATE, TIME)
	await SpriteTween.finished
	
	MainShooter.rotation = deg_to_rad(90)
	MainShooter.fire_round(
		bullets,
		FIRE_COUNT, FIRE_DURATION,
		BULLET_SPEED
	)
	await MainShooter.finished_round
	
	queue_free()




func _on_Shooter_shooter_disabled() -> void:
	if SpriteTween:
		SpriteTween.kill()
	
	queue_free()
