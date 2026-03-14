extends Node2D

const BULLET := GlobalShooter.BRIGHT_BLUE
const PARTICLE := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/Particle_CirnoDrop.tres")

var max_speed:float
var time:float

var start_angle:float
var spawner_count:float
var stack_count:float
var bullet_speed:float
var stack_speed:float

var speed:float = 0
var gravity:float = 120


func _ready():
	%BulletDull.bullet_ready.connect(_on_BulletDull_bullet_ready)
	%BulletDull.bullet_deactivate.connect(_on_BulletDull_bullet_deactivate)
	
	set_process(false)


func _process(delta):
	position.y += speed * delta
	speed = clampf(speed + (gravity * delta), 0, max_speed)




func flash() -> void:
	%BulletDull.use_parent_material = true
	
	var FlashTween = create_tween()
	FlashTween.finished.connect(_on_FlashTween_finished)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 1.0, 0)
	FlashTween.tween_interval(0.2)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 0, 0)
	FlashTween.tween_interval(0.2)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 1.0, 0)
	FlashTween.tween_interval(0.2)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 0, 0)
	FlashTween.tween_interval(0.1)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 1.0, 0)
	FlashTween.tween_interval(0.1)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 0, 0)
	FlashTween.tween_interval(0.1)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 1.0, 0)
	FlashTween.tween_interval(0.1)


func blow_up() -> void:
	GlobalStage.request_add_object.emit(PARTICLE.create_particle(global_position))
	%Sound.play()
	
	for i in spawner_count:
		%Guide.rotation = start_angle + (TAU * (float(i) / spawner_count))
		for j in stack_count:
			GlobalPool.bullet_linear_spawned.emit(BULLET, %Guide.global_transform,
				bullet_speed + (j * stack_speed)
			)
	
	%BulletDull.queue_free()
	%Timer.wait_time = 1.0
	%Timer.start()
	await %Timer.timeout
	
	queue_free()




func _on_BulletDull_bullet_ready():
	set_process(true)
	%Timer.wait_time = time
	%Timer.start()
	await %Timer.timeout
	
	flash()


func _on_BulletDull_bullet_deactivate():
	queue_free()


func _on_FlashTween_finished():
	blow_up()
