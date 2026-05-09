extends Node2D

var RNG:RandomNumberGenerator
var Boss:BossObject
var health:int
var rotation_speed:float

var origin:Vector2
var angle:float

var MainShooter:Shooter_Basic
var Bullets:Array[RowData_Column]

var fire_count:int
var fire_duration:float
var bullet_speed:float

var is_destroyed = false

const DEATH_PARTICLES := preload("res://Game/Entities/Boss/BossResources/_General/Death/Particles_BossMinor.tres")
const DISTANCE := 20.0




func _ready():
	set_process(false)
	origin = position
	angle = RNG.randf_range(0, TAU)
	
	self.position = origin + (Vector2.RIGHT.rotated(angle) * DISTANCE)
	Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	
	scale = Vector2.ZERO
	modulate.a = 0
	
	var SelfTween = create_tween().set_parallel(true)
	SelfTween.tween_property(self, "scale",      Vector2.ONE, 0.6)
	SelfTween.tween_property(self, "modulate:a", 1.0,         0.6)
	SelfTween.tween_property(self, "rotation",   TAU,         0.6)
	await SelfTween.finished
	
	set_process(true)


func _process(delta: float) -> void:
	GlobalStage.boss_hit.emit(-2)
	
	self.position = origin + (Vector2.RIGHT.rotated(angle) * DISTANCE)
	self.angle += deg_to_rad(rotation_speed) * delta
	
	var boss_position = Boss.global_position - self.global_position
	%Line.points = [
		Vector2.ZERO,
		boss_position / 2,
		boss_position
	]




func build(
		Boss:BossObject,
		health:int,
		rotation_speed_min:float,
		rotation_speed_max:float,
		direction:int,
		layout_spawner_count:int,
		fire_count:int,
		fire_duration:float,
		bullet_speed:float
	):
	
	self.Boss = Boss
	self.health = health
	self.rotation_speed = RNG.randf_range(
		rotation_speed_min,
		rotation_speed_max
	) * direction
	
	MainShooter = GlobalShooter.create_basic_shooter(layout_spawner_count)
	MainShooter.RNG = RNG
	self.add_child(MainShooter)
	
	self.fire_count = fire_count
	self.fire_duration = fire_duration
	self.bullet_speed = bullet_speed


func fire():
	MainShooter.rotation_random = true
	MainShooter.fire_round(
		Bullets,
		fire_count, fire_duration,
		bullet_speed
	)


func destroy():
	GlobalStage.request_add_object.emit(
		DEATH_PARTICLES.create_particle(self.global_position)
	)
	%Sound.play()
	set_process(false)
	await self.create_tween().tween_interval(0.2).finished
	
	queue_free()


func flash(intensity:float = 0.5, color:Color = Color(1, 1, 1, 1)):
	%Sprite.material.set_shader_parameter("flash_color",    color)
	%Sprite.material.set_shader_parameter("flash_modifier", intensity)
	%Timer.start()




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()


func _on_Enemy_collider_hit(damage) -> void:
	if GlobalStage.is_current_player_bomb(): return
	if is_destroyed: return
	
	flash()
	
	health -= damage
	if health < 0:
		is_destroyed = true
		destroy()


func _on_Timer_timeout() -> void:
	%Sprite.material.set_shader_parameter("flash_modifier", 0)


func _on_Spell_attack_a_called():
	fire()
