extends Node2D

const HELPER_08 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper08.tscn")
const BULLET_RED := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/Bullet_RumiaStarRed.tres")
const BULLET_MAG := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/Bullet_RumiaStarMagenta.tres")

const SPEED_MIN := 680
const SPEED_MAX := 760

const TIME_FIRE := 0.1
const TIME_EXPLODE := 0.8

var RNG:RandomNumberGenerator
var direction:int = 1




func fire() -> void:
	if GlobalStage.is_current_stage_clear():
		return
	
	var red_bullet = HELPER_08.instantiate()
	red_bullet.set_bullet(BULLET_RED)
	red_bullet.set_fire_time(TIME_FIRE)
	red_bullet.set_explode_time(TIME_EXPLODE)
	red_bullet.position = Vector2(
		350 + (380 * direction),
		RNG.randf_range(80, 120)
	)
	red_bullet.velocity = Vector2(
		RNG.randf_range(SPEED_MIN, SPEED_MAX) * -direction,
		0
	)
	red_bullet.rotation_speed = deg_to_rad(RNG.randf_range(120, 240)) * -direction
	red_bullet.particle_modulate = Color(1, 0, 0, 0.6)
	red_bullet.RNG = RNG
	GlobalStage.request_add_object.emit(red_bullet)
	
	var mag_bullet = HELPER_08.instantiate()
	mag_bullet.set_bullet(BULLET_MAG)
	mag_bullet.set_fire_time(TIME_FIRE)
	mag_bullet.set_explode_time(TIME_EXPLODE)
	mag_bullet.position = Vector2(
		350 + (380 * -direction),
		RNG.randf_range(80, 120)
	)
	mag_bullet.velocity = Vector2(
		RNG.randf_range(SPEED_MIN, SPEED_MAX) * direction,
		0
	)
	mag_bullet.rotation_speed = deg_to_rad(RNG.randf_range(120, 240)) * direction
	mag_bullet.particle_modulate = Color(1, 0, 1, 0.6)
	mag_bullet.RNG = RNG
	GlobalStage.request_add_object.emit(mag_bullet)
	
	direction *= -1


func disable() -> void:
	queue_free()
