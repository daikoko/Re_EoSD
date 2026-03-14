extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.SAKUYA
const SPELL_ID := 5

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Sakuya/Sprite/SpellPortrait_Sakuya.tres")
const HELPER_06 := preload("res://Game/Entities/Boss/BossResources/Sakuya/SpellResources/SakuyaHelper06.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 446658

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
@export_group("A Shooter")
@export var A_layout_column_count:int = 1
@export var A_fire_count := 1
const A_LAYOUT_SPAWNER_COUNT := 3
const A_LAYOUT_COLUMN_RANGE := 30
const A_FIRE_DURATION := 0.8
const A_BULLET_SPEED := 160
const A_BULLET_SPEED_RANGE := 40
const A_SHOOTER_ROTATION_SPEED := 90
const A_AFTER_WAIT := 2.0
var A_direction := 1

var B_Shooter:Node2D
var B1_Bullet:BulletData
var B2_Bullet:BulletData
@export_group("B Shooter")
@export_subgroup("Set 1")
@export var B1_shooter_spawner_count:int = 1
@export var B1_shooter_row_count:int = 1
const B1_BULLET_SPEED := 180
const B1_BULLET_SPEED_RANGE := 60
const B1_SHOOTER_FIRE_DURATION := 0.4
const B1_SHOOTER_DISTANCE_MIN := 280
const B1_SHOOTER_DISTANCE_MAX := 580
const B1_SHOOTER_DISTANCE_RANGE := 20
@export_subgroup("Set 2")
@export var B2_shooter_spawner_count:int = 1
@export var B2_shooter_point_count:int = 1
@export var B2_shooter_stack_count:int = 1
const B2_BULLET_SPEED := 160
const B2_SHOOTER_SHOT_RANGE := 60
const B2_SHOOTER_STACK_SPEED := 40
const B2_SHOOTER_FIRE_DURATION := 0.2
const B2_SHOOTER_DISTANCE := 480

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
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_LAYOUT_SPAWNER_COUNT,
		A_layout_column_count, A_LAYOUT_COLUMN_RANGE,
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
	
	B_Shooter = HELPER_06.instantiate()
	B_Shooter.Boss = Boss
	B_Shooter.EventHandler = EventHandler
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B1_Bullet = GlobalShooter.KNIFE_WHITE
	B2_Bullet = GlobalShooter.KNIFE_MAGENTA
	
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
	
	A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	A_Shooter.fire_round(
		A_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, A_BULLET_SPEED_RANGE
	)
	await A_Shooter.finished_round
	
	A_Shooter.rotation_speed = -deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	A_Shooter.fire_round(
		A_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, A_BULLET_SPEED_RANGE
	)
	await A_Shooter.finished_round
	
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
		B1_Bullet,
		B1_BULLET_SPEED,
		B1_BULLET_SPEED_RANGE,
		B1_shooter_spawner_count,
		B1_SHOOTER_FIRE_DURATION,
		B1_shooter_row_count,
		B1_SHOOTER_DISTANCE_MIN,
		B1_SHOOTER_DISTANCE_MAX,
		B1_SHOOTER_DISTANCE_RANGE,
		
		B2_Bullet,
		B2_BULLET_SPEED,
		B2_shooter_spawner_count,
		B2_shooter_point_count,
		B2_SHOOTER_SHOT_RANGE,
		B2_shooter_stack_count,
		B2_SHOOTER_STACK_SPEED,
		B2_SHOOTER_FIRE_DURATION,
		B2_SHOOTER_DISTANCE
	)


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
