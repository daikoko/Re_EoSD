extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.RUMIA
const SPELL_ID := 1

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Rumia/Sprite/SpellPortrait_Rumia.tres")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.4
const RAND_SEED    := 89457

var A_Shooter:Shooter_Linear
var A_Bullets:Array[RowData_Column] = []
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 3
@export var A_fire_count:int = 6
const A_LAYOUT_COLUMN_COUNT := 4
const A_LAYOUT_COLUMN_RANGE := 40
const A_FIRE_DURATION := 0.8
const A_BULLET_SPEED := 400
const A_LINEAR_TIME := 0.5
const A_LINEAR_SPEED_CHANGE := -200
const A_SHOOTER_ROTATION_SPEED := 90

var B_Shooter:Shooter_Linear
var B_Bullets:Array[RowData_Column] = []
@export_group("Shooter B")
@export var B_layout_spawner_count:int = 6
@export var B_spawn_stack_count:int = 3
const B_FIRE_COUNT := 3
const B_FIRE_DURATION := 0.6
const B_BULLET_SPEED := 360
const B_LINEAR_TIME := 0.5
const B_LINEAR_SPEED_CHANGE := -200
const B_SPAWN_STACK_SPEED := 20
const B_SHOOTER_ROTATION_SPEED := 90

var C_Shooter:Shooter_Linear
var C_Bullets:Array[RowData_Column] = []
@export_group("Shooter C")
@export var C_fire_count:int = 16
const C_LAYOUT_SPAWNER_COUNT := 6
const C_BULLET_SPEED := 250
const C_BULLET_SPEED_RANGE := 100.0

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.2
const AFTER_ATTACK_WAIT := 0.4
const AFTER_MOVE_WAIT   := 0.4
const AFTER_EVENT_WAIT  := 0.8

var Boss:BossObject
var SpellBackground:Background

var phase:int = 0




func prepare(EventHandler:Control, BossDict:Dictionary) -> float:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	Boss = BossDict["boss"]
	Boss.tree_exiting.connect(_on_Boss_tree_exiting)
	SpellBackground = BossDict["background"]
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	A_Shooter = GlobalShooter.create_linear_shooter(
		A_layout_spawner_count,
		A_LAYOUT_COLUMN_COUNT, A_LAYOUT_COLUMN_RANGE
	)
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_RED
			])
		])
	]
	
	B_Shooter = GlobalShooter.create_linear_shooter(B_layout_spawner_count)
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_YELLOW
			])
		])
	]
	
	C_Shooter = GlobalShooter.create_linear_shooter(6)
	C_Shooter.rotation_random = true
	C_Shooter.RNG = RNG
	Boss.add_child(C_Shooter)
	C_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_RED
			])
		])
	]
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return PREPARE_WAIT


func start() -> void:
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	Boss.custom_animation("AttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(START_WAIT).finished
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	next_phase()


func stop() -> void:
	if major_phase:
		Boss.charge_on(EFFECT_DEATH)
		EventHandler.slow()
		
		var SlowTimer = GlobalStage.create_timer(Boss, 1.0)
		SlowTimer.start()
		await SlowTimer.timeout
		
		Boss.charge_off()
		Boss.hide()
		EventHandler.slow_stop()
		EventHandler.shake(60, 2)
	
	stopped = true
	Boss.reset_waiters()
	A_Shooter.disable()
	B_Shooter.disable()
	C_Shooter.disable()
	
	Boss.reset_animation()
	Death.start(Boss.position)
	EventHandler.boss_spell_deactivate()
	EventHandler.calculate_bonus(base_points, bonus_points)
	GlobalStage.boss_end_phase.emit()
	
	if major_phase:
		EventHandler.play_sound_boss(SOUND_PHASE_MAJOR)
	else:
		EventHandler.play_sound_boss(SOUND_PHASE_MINOR)
	
	if hide_background:
		SpellBackground.fade_out()
	
	if hide_boss:
		Boss.disable()
	
	if move_boss:
		Boss.move_boss(GlobalStage.BOSS_DEFAULT_POSITION, AFTER_EVENT_WAIT)
	
	await Boss.create_waiter(AFTER_EVENT_WAIT).finished
	event_ended.emit()


func get_boss_id() -> int:
	return BOSS_ID


func get_spell_id() -> int:
	return SPELL_ID 




func next_phase() -> void:
	if stopped:
		return
	
	if phase == 0:
		attack_a()
		phase += 1
	elif phase == 1:
		attack_b()
		attack_c()
		phase = 0


func attack_a() -> void:
	Boss.custom_animation("AttackA")
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	A_Shooter.fire_round(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0, 
		0, 0,
		0, A_LINEAR_TIME, 
		A_LINEAR_SPEED_CHANGE
	)
	await A_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	move()


func attack_b() -> void:
	Boss.custom_animation("AttackA")
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	B_Shooter.rotation_speed = deg_to_rad(B_SHOOTER_ROTATION_SPEED)
	B_Shooter.fire_round(
		B_Bullets, 
		B_FIRE_COUNT, B_FIRE_DURATION,
		B_BULLET_SPEED, 0, 
		0, 0,
		0, B_LINEAR_TIME, 
		B_LINEAR_SPEED_CHANGE, 0,
		0, 0,
		B_spawn_stack_count, B_SPAWN_STACK_SPEED
	)


func attack_c() -> void:
	await Boss.create_waiter(B_FIRE_DURATION).finished
	
	C_Shooter.fire_round(
		C_Bullets, 
		C_fire_count, 0,
		C_BULLET_SPEED, C_BULLET_SPEED_RANGE
	)
	await C_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	move()


func move() -> void:
	var rand_pos = GlobalStage.random_position(
		BOUND_RIGHT, BOUND_LEFT, BOUND_TOP, BOUND_BOTTOM, 
		Boss.position, DISTANCE, RNG
	)
	
	await Boss.move_boss(rand_pos, TIME).finished
	await Boss.create_waiter(AFTER_MOVE_WAIT).finished
	
	next_phase()




func _on_Boss_tree_exiting():
	stopped = true
