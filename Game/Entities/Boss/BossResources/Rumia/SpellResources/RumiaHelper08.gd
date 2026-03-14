extends Node2D

const BULLET := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/Bullet_RumiaStarYellow.tres")
const PARTICLES := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/Particles_RumiaStar.tres")

var velocity:Vector2
var rotation_speed:float

var particle_modulate:Color

var RNG:RandomNumberGenerator
var MainShooter:Shooter_Basic
var MainBullets:Array[RowData_Column]




func _ready() -> void:
	MainShooter = GlobalShooter.create_basic_shooter(1)
	MainShooter.rotation = deg_to_rad(-90)
	MainShooter.immunity_time = 2.8
	MainShooter.RNG = RNG
	self.add_child(MainShooter)


func _process(delta:float) -> void:
	self.position += velocity * delta
	%BulletDull.rotation += rotation_speed * delta




func fire() -> void:
	MainShooter.fire_row(
		MainBullets[0],
		RNG.randf_range(80, 120), 0,
		RNG.randf_range(0, 360), RNG.randf_range(60, 120),
		120
	)


func explode() -> void:
	MainShooter.rotation_random = true
	MainShooter.fire_round_gravity(
		[
			RowData_Column.new([
				ColumnData_Bullet.new([
					BULLET
				])
			])
		],
		18, 0,
		160, 80,
		RNG.randf_range(0, 360), RNG.randf_range(60, 120),
		90
	)
	
	var particle = PARTICLES.create_particle(self.position)
	particle.modulate = particle_modulate
	GlobalStage.request_add_object.emit(particle)
	
	%Sound.play()
	%BulletDull.hide()
	%FireTimer.stop()
	MainShooter.disable()
	
	await self.create_tween().tween_interval(1.0).finished
	
	queue_free()


func set_bullet(data:BulletData) -> void:
	%BulletDull.data = data
	MainBullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				data
			])
		])
	]


func set_fire_time(time:float) -> void:
	%FireTimer.wait_time = time


func set_explode_time(time:float) -> void:
	%ExplodeTimer.wait_time = time




func _on_FireTimer_timeout() -> void:
	fire()


func _on_ExplodeTimer_timeout() -> void:
	explode()


func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
