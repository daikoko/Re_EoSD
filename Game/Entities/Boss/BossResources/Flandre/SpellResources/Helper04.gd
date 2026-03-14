extends Node2D

var health:int
var speed:float

var rotation_start:float
var rotation_speed:float

var time:float
var primed:bool
var disabled:bool

var bomb:bool
var shooter_01:Shooter_Basic
var shooter_02:Shooter_Basic
var bullets:Array[RowData_Column]

var bomb_fire_count  =   7
var bomb_rotation    =  10
var bomb_speed       = 140
var bomb_stack_speed =  15

const PARTICLES_MINOR := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Particle_FlandreDropMinor.tres")
const PARTICLES_MAJOR := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Particle_FlandreDropMajor.tres")




func _ready() -> void:
	pass


func _process(delta:float) -> void:
	self.position += Vector2.DOWN * speed * delta
	self.rotation += rotation_speed * delta
	
	self.time -= delta
	if (time <= 0) and not primed:
		primed = true
		detonate()




func build(
		template:BulletData,
		health:int,
		speed:float,
		rotation_start:float,
		rotation_speed:float,
		time:float,
		spawners:int,
		bullet:BulletData,
		bomb:bool
	) -> void:
	
	%BulletDull.data = template
	%Enemy.set_shape(template.shape)
	
	self.health         = health
	self.speed          = speed
	
	self.rotation_start = rotation_start
	self.rotation_speed = rotation_speed
	
	self.time           = time
	self.bomb           = bomb
	
	if bomb:
		shooter_01 = GlobalShooter.create_basic_shooter(spawners)
		shooter_02 = GlobalShooter.create_basic_shooter(spawners)
		add_child(shooter_01)
		add_child(shooter_02)
	else:
		shooter_01 = GlobalShooter.create_basic_shooter(spawners)
		add_child(shooter_01)
	
	bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				bullet
			])
		])
	]




func detonate():
	if bomb: return
	
	%BulletDull.use_parent_material = true
	
	var FlashTween = create_tween()
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
	await FlashTween.finished
	
	if disabled: return
	GlobalStage.request_add_object.emit(
		PARTICLES_MINOR.create_particle(self.global_position)
	)
	shooter_01.rotation = rotation_start
	shooter_01.fire_round_stack(
		bullets,
		1, 0,
		180, 0,
		0, 0,
		4, 20
	)
	%BulletDull.deactivate()


func detonate_bomb() -> void:
	shooter_01.rotation = rotation_start
	shooter_02.rotation = rotation_start
	for i in bomb_fire_count:
		shooter_01.fire_row(
			bullets[0],
			bomb_speed + (bomb_stack_speed * i)
		)
		shooter_02.fire_row(
			bullets[0],
			bomb_speed + (bomb_stack_speed * i)
		)
		
		shooter_01.rotation += deg_to_rad(bomb_rotation)
		shooter_02.rotation -= deg_to_rad(bomb_rotation)
	
	%BulletDull.deactivate()


func flash():
	%BulletDull.material.set_shader_parameter("flash_modifier", 0.8)
	%FlashTimer.start()




func _on_BulletDull_bullet_deactivate() -> void:
	disabled = true
	
	%Enemy.disable()
	if shooter_01:
		shooter_01.disable()
	if shooter_02:
		shooter_02.disable()
	
	await self.create_tween().tween_interval(2.0).finished
	
	queue_free()


func _on_Enemy_collider_hit(damage) -> void:
	if health <= 0:
		return
	
	health -= damage
	flash()
	
	if health <= 0:
		if bomb:
			detonate_bomb()
		else:
			GlobalStage.request_add_object.emit(
				PARTICLES_MINOR.create_particle(self.global_position)
			)
			%BulletDull.deactivate()
	else:
		%Sound_Hit.play()


func _on_FlashTimer_timeout() -> void:
	%BulletDull.material.set_shader_parameter("flash_modifier", 0)
