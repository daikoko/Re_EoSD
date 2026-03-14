extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.SAKUYA
const SPELL_ID := 1

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Sakuya/Sprite/SpellPortrait_Sakuya.tres")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 446658

var A1_Shooter:Shooter_Basic
var A2_Shooter:Shooter_Basic
var A3_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column]
var A2_Bullets:Array[RowData_Column]
var A3_Bullets:Array[RowData_Column]
@export_group("A Shooter")
@export_subgroup("A1")
@export var A1_layout_spawner_count:int = 1
@export var A1_fire_count:int = 1
const A1_LAYOUT_COLUMN_COUNT := 4
const A1_LAYOUT_COLUMN_RANGE := 40
const A1_LAYOUT_SHOT_RANGE := 210
const A1_FIRE_DURATION := 2.4
const A1_BULLET_SPEED := 200
@export_subgroup("A2")
@export var A2_layout_spawner_count:int = 1
@export var A2_fire_count:int = 1
const A2_LAYOUT_COLUMN_COUNT := 3
const A2_LAYOUT_COLUMN_RANGE := 40
const A2_LAYOUT_SHOT_RANGE := 160
const A2_FIRE_DURATION := 2.0
const A2_BULLET_SPEED := 240
const A2_PRIOR_WAIT := A1_FIRE_DURATION - A2_FIRE_DURATION
@export_subgroup("A3")
@export var A3_layout_spawner_count:int = 1
@export var A3_fire_count:int = 1
const A3_FIRE_DURATION := 2.0
const A3_BULLET_SPEED := 260
const A_SHOOTER_ROTATION_START := 90

var B1_Shooter:Shooter_Basic
var B2_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
@export_group("B Shooter")
@export var B_layout_spawner_count:int = 1
@export var B_fire_count:int = 16
const B_LAYOUT_SHOT_RANGE := 30
const B_FIRE_DURATION := 1.6
const B_BULLET_SPEED := 180
const B_SPAWN_STACK_COUNT := 3
const B_SPAWN_STACK_SPEED := 40
const B_SHOOTER_ROTATION_START := -90
const B_SHOOTER_ROTATION_ARC := 210
const B_PRIOR_WAIT := 2.0
const B_AFTER_WAIT := 0.2

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
	
	A1_Shooter = GlobalShooter.create_basic_shooter(
		A1_layout_spawner_count,
		A1_LAYOUT_COLUMN_COUNT, A1_LAYOUT_COLUMN_RANGE,
		A1_LAYOUT_SHOT_RANGE
	)
	A1_Shooter.RNG = RNG
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_BLUE
			])
		])
	]
	Boss.add_child(A1_Shooter)
	
	A2_Shooter = GlobalShooter.create_basic_shooter(
		A2_layout_spawner_count,
		A2_LAYOUT_COLUMN_COUNT, A2_LAYOUT_COLUMN_RANGE,
		A2_LAYOUT_SHOT_RANGE
	)
	A2_Shooter.RNG = RNG
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_RED
			])
		])
	]
	Boss.add_child(A2_Shooter)
	
	A3_Shooter = GlobalShooter.create_basic_shooter(
		A3_layout_spawner_count
	)
	A3_Shooter.RNG = RNG
	A3_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_MAGENTA
			])
		])
	]
	Boss.add_child(A3_Shooter)
	
	B1_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count,
		1, 360,
		B_LAYOUT_SHOT_RANGE
	)
	B2_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count,
		1, 360,
		B_LAYOUT_SHOT_RANGE
	)
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_WHITE
			])
		])
	]
	Boss.add_child(B1_Shooter)
	Boss.add_child(B2_Shooter)
	
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
	A1_Shooter.disable()
	A2_Shooter.disable()
	A3_Shooter.disable()
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
		attack_a(false)
		attack_b()
		phase += 1
	elif phase == 1:
		attack_a(true)
		attack_b()
		phase = 0


func attack_a(additional:bool) -> void:
	A1_Shooter.rotation = deg_to_rad(A_SHOOTER_ROTATION_START)
	A2_Shooter.rotation = deg_to_rad(A_SHOOTER_ROTATION_START)
	A3_Shooter.rotation = deg_to_rad(A_SHOOTER_ROTATION_START)
	
	A1_Shooter.fire_round(
		A1_Bullets,
		A1_fire_count, A1_FIRE_DURATION,
		A1_BULLET_SPEED
	)
	
	await GlobalStage.create_timer_short(Boss, A2_PRIOR_WAIT).timeout
	if (stopped): return
	
	A2_Shooter.fire_round(
		A2_Bullets,
		A2_fire_count, A2_FIRE_DURATION,
		A2_BULLET_SPEED
	)
	
	if additional:
		pass
	else:
		return
	
	A3_Shooter.fire_round(
		A3_Bullets,
		A3_fire_count, A3_FIRE_DURATION,
		A3_BULLET_SPEED
	)


func attack_b() -> void:
	Boss.custom_animation("AttackA")
	
	await GlobalStage.create_timer_short(Boss, B_PRIOR_WAIT).timeout
	if (stopped): return
	
	B1_Shooter.rotation = deg_to_rad(B_SHOOTER_ROTATION_START)
	B1_Shooter.rotation_speed = deg_to_rad(
		B_SHOOTER_ROTATION_ARC / B_FIRE_DURATION
	)
	
	B2_Shooter.rotation = deg_to_rad(B_SHOOTER_ROTATION_START)
	B2_Shooter.rotation_speed = -deg_to_rad(
		B_SHOOTER_ROTATION_ARC / B_FIRE_DURATION
	)
	
	B1_Shooter.fire_round_stack(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, 0,
		0, 0,
		B_SPAWN_STACK_COUNT, B_SPAWN_STACK_SPEED
	)
	B2_Shooter.fire_round_stack(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, 0,
		0, 0,
		B_SPAWN_STACK_COUNT, B_SPAWN_STACK_SPEED
	)
	await B1_Shooter.finished_round
	
	await GlobalStage.create_timer_short(Boss, B_AFTER_WAIT).timeout
	if (stopped): return
	
	Boss.return_animation()
	await GlobalStage.create_timer_short(Boss, AFTER_ATTACK_WAIT).timeout
	if (stopped): return
	
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
