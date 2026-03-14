extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.SAKUYA
const SPELL_ID := 7

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Sakuya/Sprite/SpellPortrait_Sakuya.tres")
const HELPER_08 := preload("res://Game/Entities/Boss/BossResources/Sakuya/SpellResources/SakuyaHelper08.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 722215

var A_Shooter:Shooter_Linear
var A_Bullets:Array[RowData_Column]
@export_group("A Shooter")
@export var A_layout_spawner_count:int = 1
@export var A_fire_count := 1
const A_FIRE_DURATION := 0.8
const A_BULLET_SPEED := 120
const A_LINEAR_DELAY := 0.6
const A_LINEAR_TIME := 1.2
const A_LINEAR_SPEED_CHANGE := 120
const A_SHOOTER_ROTATION_SPEED := 180
const A_AFTER_WAIT := 2.0
var A_direction := 1

var B_Shooter:Node2D
var B1_Bullet:BulletData
var B2_Bullet:BulletData
var B3_Bullet:BulletData
var B4_Bullet:BulletData
@export_group("B Shooter")
@export_subgroup("Set 1")
@export var B1_shooter_line_count:int = 1
@export var B1_shooter_fire_count:int = 1
const B1_BULLET_SPEED := 560
const B1_BULLET_SPEED_CHANGE := -30
const B1_SHOOTER_FIRE_DURATION := 1.0
const B1_SHOOTER_WIDTH := 120
@export_subgroup("Set 2")
@export var B2_shooter_line_count:int = 1
@export var B2_shooter_fire_count:int = 1
const B2_BULLET_SPEED := 520
const B2_BULLET_SPEED_CHANGE := 0
const B2_SHOOTER_FIRE_DURATION := 1.0
const B2_SHOOTER_SHOT_RANGE := 60
@export_subgroup("Set 3")
@export var B3_shooter_line_count:int = 1
@export var B3_shooter_fire_count:int = 1
const B3_BULLET_SPEED := 360
const B3_SHOOTER_FIRE_DURATION := 1.0
const B3_SHOOTER_DISTANCE := 120
@export_subgroup("Set 4")
@export var B4_shooter_spawner_count:int = 1
@export var B4_shooter_fire_count:int = 1
const B4_BULLET_SPEED := 220
const B4_SHOOTER_FIRE_DURATION := 0.8
const B4_SHOOTER_DISTANCE := 40
var B_phase:int = 0

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.4
const AFTER_ATTACK_WAIT := 0.5
const AFTER_MOVE_WAIT   := 0.5
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
		A_layout_spawner_count
	)
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	
	B_Shooter = HELPER_08.instantiate()
	B_Shooter.Boss = Boss
	B_Shooter.EventHandler = EventHandler
	B_Shooter.RNG = RNG
	B_Shooter.create_self(
		B1_SHOOTER_WIDTH,
		B1_shooter_line_count,
		B1_shooter_fire_count,
		B2_SHOOTER_SHOT_RANGE,
		B2_shooter_line_count,
		B2_shooter_fire_count,
		B3_SHOOTER_DISTANCE,
		B3_shooter_line_count,
		B3_shooter_fire_count,
	)
	Boss.add_child(B_Shooter)
	B1_Bullet = GlobalShooter.KNIFE_WHITE
	B2_Bullet = GlobalShooter.KNIFE_WHITE
	B3_Bullet = GlobalShooter.KNIFE_RED
	B4_Bullet = GlobalShooter.KUNAI_WHITE
	
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
		attack_a()
		attack_b()
		phase = 0


func attack_a() -> void:
	Boss.custom_animation("AttackA")
	
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED) * A_direction
	A_Shooter.fire_round(
		A_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
		0, 0,
		A_LINEAR_DELAY, A_LINEAR_TIME,
		A_LINEAR_SPEED_CHANGE
	)
	await A_Shooter.finished_round
	
	A_direction *= -1
	
	Boss.return_animation()
	await GlobalStage.create_timer_short(Boss, AFTER_ATTACK_WAIT).timeout
	if (stopped): return
	
	await GlobalStage.create_timer_short(Boss, A_AFTER_WAIT).timeout
	if (stopped): return
	
	move()


func attack_b() -> void:
	await GlobalStage.create_timer_short(Boss, A_FIRE_DURATION).timeout
	if (stopped): return
	
	B_Shooter.fire(
		B_phase,
		
		B1_Bullet,
		B1_BULLET_SPEED,
		B1_BULLET_SPEED_CHANGE,
		B1_shooter_line_count,
		B1_shooter_fire_count,
		B1_SHOOTER_FIRE_DURATION,
		
		B2_Bullet,
		B2_BULLET_SPEED,
		B2_BULLET_SPEED_CHANGE,
		B2_shooter_line_count,
		B2_shooter_fire_count,
		B2_SHOOTER_FIRE_DURATION,
		
		B3_Bullet,
		B3_BULLET_SPEED,
		B3_shooter_line_count,
		B3_shooter_fire_count,
		B3_SHOOTER_FIRE_DURATION,
		
		B4_Bullet,
		B4_BULLET_SPEED,
		B4_shooter_spawner_count,
		B4_shooter_fire_count,
		B4_SHOOTER_FIRE_DURATION,
		B4_SHOOTER_DISTANCE
	)
	
	if B_phase == 0:   B_phase = 1
	elif B_phase == 1: B_phase = 0


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
