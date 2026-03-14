extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.REMILIA
const SPELL_ID := 5

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Remilia/Sprite/SpellPortrait_Remilia.tres")
const HELPER_07 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper07.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 4.2
const RAND_SEED    := 449962

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D
var A_Bullet:BulletData
@export_group("Attack A")
@export var A_circle_count:int
@export var A_min_bullet_count:int
@export var A_max_bullet_count:int
const A_FIRE_DURATION := 2.4
const A_START_DISTANCE := 140.0
const A_END_DISTANCE := 800.0
const A_START_TIME := 0.4
const A_END_TIME := 2.0
const A_START_ROTATION := 20.0
const A_END_ROTATION := 0.0

var B1_Shooter:Shooter_Basic
var B2_Shooter:Shooter_Basic
var B1_Bullets:Array[RowData_Column]
var B2_Bullets:Array[RowData_Column]
@export_group("Attack B")
@export_subgroup("Set 1")
@export var B1_layout_spawner_count:int
@export var B1_fire_count:int
@export_subgroup("Set 2")
@export var B2_layout_spawner_count:int
@export var B2_fire_count:int
const B_LAYOUT_COLUMN_RANGE := 30.0
const B_FIRE_DURATION := 1.0
const B_BULLET_SPEED := 140.0
const B_BULLET_SPEED_RANGE := 40.0
const B_DELAY := 0.2
var B_direction := 1

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.4
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
	
	A_Shooter = HELPER_07.instantiate()
	A_Shooter.RNG = RNG
	A_Bullet = GlobalShooter.LARGE_RED
	Boss.add_child(A_Shooter)
	
	B1_Shooter = GlobalShooter.create_basic_shooter(
		B1_layout_spawner_count,
		1, B_LAYOUT_COLUMN_RANGE
	)
	B1_Shooter.RNG = RNG
	B1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	Boss.add_child(B1_Shooter)
	
	B2_Shooter = GlobalShooter.create_basic_shooter(
		B2_layout_spawner_count,
		1, B_LAYOUT_COLUMN_RANGE
	)
	B2_Shooter.RNG = RNG
	B2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.MEDIUM_RED
			])
		])
	]
	Boss.add_child(B2_Shooter)
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return PREPARE_WAIT


func start() -> void:
	if special_animation:
		Boss.special_function("Idle_Transition")
		await Boss.animation_finished
	
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
	attack_a()
	attack_b_loop()


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
	B1_Shooter.disable()
	B2_Shooter.disable()
	
	Boss.reset_animation()
	Death.start(Boss.position)
	EventHandler.boss_spell_deactivate()
	EventHandler.calculate_bonus(base_points, bonus_points)
	GlobalStage.boss_end_phase.emit()
	
	if major_phase:
		EventHandler.play_sound_boss(SOUND_PHASE_MAJOR)
	else:
		EventHandler.play_sound_boss(SOUND_PHASE_MINOR)
	
	if hide_background and SpellBackground != null:
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
		phase = 0


func attack_a():
	Boss.custom_animation("AttackA")
	
	var direction = 1
	for i in A_circle_count:
		A_Shooter.fire(
			A_Bullet,
			roundi(A_min_bullet_count + ((A_max_bullet_count - A_min_bullet_count) * (float(i) / A_circle_count))),
			(A_START_DISTANCE + ((A_END_DISTANCE - A_START_DISTANCE) * (float(i) / A_circle_count))),
			(A_START_TIME + ((A_END_TIME - A_START_TIME) * (float(i) / A_circle_count))),
			(A_START_ROTATION + ((A_END_ROTATION - A_START_ROTATION) * (float(i) / A_circle_count))) * direction
		)
		
		direction *= -1
		await Boss.create_waiter(A_FIRE_DURATION / A_circle_count).finished


func attack_b_loop():
	var rotation = RNG.randf_range(0, TAU)
	
	B1_Shooter.rotation = rotation
	B1_Shooter.rotation_speed = (TAU / B_FIRE_DURATION) * B_direction
	
	B2_Shooter.rotation = rotation
	B2_Shooter.rotation_speed = (TAU / B_FIRE_DURATION) * B_direction
	
	B1_Shooter.fire_round(
		B1_Bullets,
		B1_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE
	)
	
	B2_Shooter.fire_round(
		B2_Bullets,
		B2_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE
	)
	
	await B1_Shooter.finished_round
	await Boss.create_waiter(B_DELAY).finished
	
	B_direction *= -1
	
	attack_b_loop()


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
