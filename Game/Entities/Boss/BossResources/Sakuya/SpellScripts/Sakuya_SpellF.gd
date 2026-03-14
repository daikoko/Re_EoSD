extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.SAKUYA
const SPELL_ID := 6

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Sakuya/Sprite/SpellPortrait_Sakuya.tres")
const HELPER_07 := preload("res://Game/Entities/Boss/BossResources/Sakuya/SpellResources/SakuyaHelper07.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 463558

var A_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column]
var A2_Bullets:Array[RowData_Column]
@export_group("A Shooter")
@export var A_layout_spawner_count:int = 1
@export var A_fire_count := 1
@export var A_spawn_stack_count:int = 1
const A_FIRE_DURATION := 0.4
const A_BULLET_SPEED := 160
const A_SPAWN_STACK_SPEED := 20
const A_SHOOTER_ROTATION_SPEED := 90
const A_AFTER_WAIT := 2.0
var A_direction := 1

var B_Shooter:Node2D
var B1_Bullet:BulletData
var B2_Bullet:BulletData
var B3_Bullet:BulletData
@export_group("B Shooter")
@export_subgroup("Set 1")
@export var B1_shooter_spawner_count:int = 1
@export var B1_shooter_column_count:int = 1
@export var B1_shooter_fire_count:int = 1
const B1_BULLET_SPEED := 120
const B1_BULLET_SPEED_CHANGE := 40
const B1_SHOOTER_COLUMN_RANGE := 24
const B1_SHOOTER_FIRE_DURATION := 0.4
const B1_SHOOTER_DISTANCE := 80
const B1_SHOOTER_DISTANCE_CHANGE := 30
@export_subgroup("Set 2")
@export var B2_shooter_spawner_count:int = 1
@export var B2_shooter_fire_count:int = 1
const B2_BULLET_SPEED := 180
const B2_SHOOTER_SHOT_RANGE := 60
const B2_SHOOTER_FIRE_DURATION := 0.4
const B2_SHOOTER_DISTANCE := 80
@export_subgroup("Set 3")
@export var B3_shooter_spawn_count:int = 1
@export var B3_shooter_fire_count:int = 1
const B3_BULLET_SPEED := 180
const B3_BULLET_SPEED_RANGE := 20
const B3_SHOOTER_FIRE_DURATION := 0.4

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
		A_layout_spawner_count
	)
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_BLUE
			])
		])
	]
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_WHITE
			])
		])
	]
	
	B_Shooter = HELPER_07.instantiate()
	B_Shooter.Boss = Boss
	B_Shooter.EventHandler = EventHandler
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B1_Bullet = GlobalShooter.KNIFE_RED
	B2_Bullet = GlobalShooter.KUNAI_MAGENTA
	B3_Bullet = GlobalShooter.KUNAI_WHITE
	
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
	A_Shooter.fire_round_stack(
		A1_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
		0, 0,
		A_spawn_stack_count, A_SPAWN_STACK_SPEED
	)
	await A_Shooter.finished_round
	
	A_Shooter.rotation += deg_to_rad(float(180) / A_layout_spawner_count)
	A_Shooter.rotation_speed = -deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	A_Shooter.fire_round_stack(
		A2_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
		0, 0,
		A_spawn_stack_count, A_SPAWN_STACK_SPEED
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
		B1_BULLET_SPEED_CHANGE,
		B1_shooter_spawner_count,
		B1_shooter_column_count,
		B1_SHOOTER_COLUMN_RANGE,
		B1_shooter_fire_count,
		B1_SHOOTER_FIRE_DURATION,
		B1_SHOOTER_DISTANCE,
		B1_SHOOTER_DISTANCE_CHANGE,
		
		B2_Bullet,
		B2_BULLET_SPEED,
		B2_shooter_spawner_count,
		B2_SHOOTER_SHOT_RANGE,
		B2_shooter_fire_count,
		B2_SHOOTER_FIRE_DURATION,
		B2_SHOOTER_DISTANCE,
		
		B3_Bullet,
		B3_BULLET_SPEED,
		B3_BULLET_SPEED_RANGE,
		B3_shooter_spawn_count,
		B3_shooter_fire_count,
		B3_SHOOTER_FIRE_DURATION
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
