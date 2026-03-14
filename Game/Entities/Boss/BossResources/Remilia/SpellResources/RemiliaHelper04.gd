extends Node2D

var RNG:RandomNumberGenerator

var velocity:Vector2
var rotation_speed:float

var layout_spawner_count:int

var fire_count:int
var fire_duration:float
var bullet_speed:float

var spawners:Array = []
var decoy_bullets:Array = []

var mute:bool

const BULLET_DULL := preload("res://Game/Objects/Bullets/BulletScripts/BulletDull.tscn")
const BULLET_REMILIASTAR := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/Bullet_RemiliaStar.tres")
const PARTICLE_REMILIASTAR := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/Particle_RemiliaStar.tres")

const DISTANCE := 52.0

const DELAY := 0.2
const GENERATOR_DURATION := 0.6

signal generate_finished
signal fire_finished




func _ready() -> void:
	start()


func _process(delta:float) -> void:
	self.position += velocity * delta
	self.rotation += rotation_speed * delta




func build(
		velocity:Vector2, 
		rotation_speed:float,
		layout_spawner_count:float,
		fire_count:int,
		fire_duration:float,
		bullet_speed:float
	) -> void:
	
	self.velocity = velocity
	self.rotation_speed = rotation_speed
	
	self.layout_spawner_count = layout_spawner_count
	
	self.fire_count = fire_count
	self.fire_duration = fire_duration
	self.bullet_speed = bullet_speed


func start():
	%Timer.wait_time = DELAY
	%Timer.start()
	await %Timer.timeout
	
	generate()
	await generate_finished
	
	fire()
	await  fire_finished
	
	release()


func generate():
	var angle = RNG.randf_range(0, TAU)
	var angle_step = TAU / layout_spawner_count
	
	%Timer.wait_time = GENERATOR_DURATION / layout_spawner_count
	%Timer.start()
	for _i in layout_spawner_count:
		var bullet = BULLET_DULL.instantiate()
		bullet.data = GlobalShooter.BRIGHT_RED
		bullet.hit_immunity = true
		bullet.visibility_immunity = true
		bullet.position = Vector2.RIGHT.rotated(angle) * DISTANCE
		bullet.rotation = angle
		decoy_bullets.append(bullet)
		self.add_child(bullet)
		
		var spawner = Marker2D.new()
		spawner.rotation = angle
		spawners.append(spawner)
		self.add_child(spawner)
		
		angle += angle_step
		
		await %Timer.timeout
	
	generate_finished.emit()


func fire():
	%Timer.wait_time = fire_duration / fire_count
	%Timer.start()
	for _i in fire_count:
		for spawner in decoy_bullets:
			GlobalPool.bullet_gravity_spawned.emit(
				GlobalShooter.BRIGHT_RED, spawner.global_transform,
				bullet_speed
			)
		
		if !mute:
			%Sound.play()
		
		await %Timer.timeout
	
	fire_finished.emit()


func release():
	GlobalStage.request_add_object.emit(PARTICLE_REMILIASTAR.create_particle(global_position))
	
	%BulletDull.deactivate()
	for bullet in decoy_bullets:
		bullet.deactivate()
	
	for spawner in spawners:
		GlobalPool.bullet_gravity_spawned.emit(
			BULLET_REMILIASTAR, spawner.global_transform,
			bullet_speed * 1.4
		)




func _on_BulletDull_bullet_deactivate() -> void:
	%Timer.stop()
	%Delay.start()
	await %Delay.timeout
	
	queue_free()
