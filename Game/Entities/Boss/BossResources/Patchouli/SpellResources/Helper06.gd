extends Node2D

const LAYOUT_SHOOTER_SPAWN_COUNT := 2
const BULLET_SPEED := 160.0
const BULLET_SPEED_RANGE := 40.0

var MainShooter:Shooter_Basic
var Bullets:RowData_Column

var RNG:RandomNumberGenerator




func _ready() -> void:
	%Sound.play()
	
	MainShooter = GlobalShooter.create_basic_shooter(
		LAYOUT_SHOOTER_SPAWN_COUNT
	)
	MainShooter.RNG = RNG
	Bullets = RowData_Column.new([
		ColumnData_Bullet.new([
			GlobalShooter.SPADE_YELLOW
		])
	])
	self.add_child(MainShooter)
	await GlobalStage.create_timer_short(self, 0.6).timeout
	
	MainShooter.rotation = randf_range(0, TAU)
	MainShooter.fire_row(
		Bullets,
		BULLET_SPEED, BULLET_SPEED_RANGE
	)
	%BulletDull.deactivate()




func _on_BulletDull_bullet_deactivate() -> void:
	await GlobalStage.create_timer_short(self, 0.4).timeout
	
	queue_free()
