extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.REMILIA

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Remilia/Sprite/SpellPortrait_Remilia.tres")
const BULLET_REMILIA := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/Bullet_Remilia.tres")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 446658

@export_group("Special")
@export var special_animation:bool = false

var A1_Shooter:Shooter_Basic
var A2_Shooter:Shooter_Basic
var A3_Shooter:Shooter_Basic
var A4_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column]
var A2_Bullets:Array[RowData_Column]
var A3_Bullets:Array[RowData_Column]
var A4_Bullets:Array[RowData_Column]
@export_group("A Shooter")
@export_subgroup("A1")
@export var A1_layout_spawner_count:int = 1
@export var A1_fire_count:int = 1
const A1_FIRE_DURATION := 1.0
const A1_BULLET_SPEED := 180
const A1_SHOOTER_ROTATION_SPEED := 280
@export_subgroup("A2")
@export var A2_layout_spawner_count:int = 1
@export var A2_fire_count:int = 1
const A2_FIRE_DURATION := 1.0
const A2_BULLET_SPEED := 200
const A2_SHOOTER_ROTATION_SPEED := -120
@export_subgroup("A3")
@export var A3_layout_spawner_count:int = 1
@export var A3_fire_count:int = 1
const A3_FIRE_DURATION := 0.2
const A3_BULLET_SPEED := 240
const A3_SHOOTER_ROTATION_SPEED := 180
const A3_SHOOTER_DELAY := 0.6
@export_subgroup("A4")
@export var A4_layout_spawner_count:int = 1
@export var A4_fire_count:int = 1
const A4_FIRE_DURATION := 0.4
const A4_BULLET_SPEED := 240
const A4_SHOOTER_ROTATION_SPEED := -180
const A4_SHOOTER_DELAY := 0.8

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.2
const START_WAIT_ADD    := 0.8
const AFTER_ATTACK_WAIT := 0.4
const AFTER_MOVE_WAIT   := 2.4
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
	)
	A1_Shooter.RNG = RNG
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.LARGE_RED
			])
		])
	]
	Boss.add_child(A1_Shooter)
	
	A2_Shooter = GlobalShooter.create_basic_shooter(
		A2_layout_spawner_count,
	)
	A2_Shooter.RNG = RNG
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.MEDIUM_RED
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
				GlobalShooter.SPADE_MAGENTA
			])
		])
	]
	Boss.add_child(A3_Shooter)
	
	A4_Shooter = GlobalShooter.create_basic_shooter(
		A4_layout_spawner_count
	)
	A4_Shooter.RNG = RNG
	A4_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				BULLET_REMILIA
			])
		])
	]
	Boss.add_child(A4_Shooter)
	
	if special_animation:
		Boss.charge_on(EFFECT_CHARGE)
		EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return PREPARE_WAIT


func start() -> void:
	if special_animation:
		Boss.special_function("Idle_Transition")
		await Boss.animation_finished
		
		Boss.charge_off()
		Boss.spell_effect(EFFECT_SPELL)
		EventHandler.play_sound_boss(SOUND_SPELL)
		
		await Boss.create_waiter(START_WAIT_ADD).finished
	
	if show_background:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(START_WAIT).finished
	
	stopped = false
	non_started.emit()
	Boss.enable()
	
	attack_loop_a1()
	attack_loop_a2()
	attack_loop_a3()
	attack_loop_a4()
	
	await Boss.create_waiter(AFTER_MOVE_WAIT).finished
	move_loop()


func stop() -> void:
	stopped = true
	Boss.reset_waiters()
	A1_Shooter.disable()
	A2_Shooter.disable()
	A3_Shooter.disable()
	A4_Shooter.disable()
	
	Boss.reset_animation()
	Death.start(Boss.position)
	EventHandler.play_sound_boss(SOUND_PHASE_MINOR)
	GlobalStage.boss_end_phase.emit()
	
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




func next_phase() -> void:
	if stopped:
		return
	
	pass


func attack_loop_a1() -> void:
	A1_Shooter.rotation_speed = deg_to_rad(A1_SHOOTER_ROTATION_SPEED)
	
	A1_Shooter.fire_round(
		A1_Bullets,
		A1_fire_count, A1_FIRE_DURATION,
		A1_BULLET_SPEED
	)
	
	await A1_Shooter.finished_round
	if (stopped): return
	
	attack_loop_a1()


func attack_loop_a2() -> void:
	A2_Shooter.rotation_speed = deg_to_rad(A2_SHOOTER_ROTATION_SPEED)
	
	A2_Shooter.fire_round(
		A2_Bullets,
		A2_fire_count, A2_FIRE_DURATION,
		A2_BULLET_SPEED
	)
	
	await A2_Shooter.finished_round
	if (stopped): return
	
	attack_loop_a2()


func attack_loop_a3() -> void:
	A3_Shooter.rotation_speed = deg_to_rad(A3_SHOOTER_ROTATION_SPEED)
	
	A3_Shooter.fire_round(
		A3_Bullets,
		A3_fire_count, A3_FIRE_DURATION,
		A3_BULLET_SPEED
	)
	
	await A3_Shooter.finished_round
	await Boss.create_tween().tween_interval(A3_SHOOTER_DELAY).finished
	if (stopped): return

	attack_loop_a3()


func attack_loop_a4() -> void:
	A4_Shooter.rotation_speed = deg_to_rad(A4_SHOOTER_ROTATION_SPEED)
	
	A4_Shooter.fire_round(
		A4_Bullets,
		A4_fire_count, A4_FIRE_DURATION,
		A4_BULLET_SPEED
	)
	
	await A4_Shooter.finished_round
	await Boss.create_tween().tween_interval(A4_SHOOTER_DELAY).finished
	if (stopped): return
	
	attack_loop_a4()


func move_loop() -> void:
	var rand_pos = GlobalStage.random_position(
		BOUND_RIGHT, BOUND_LEFT, BOUND_TOP, BOUND_BOTTOM, 
		Boss.position, DISTANCE, RNG
	)
	
	await Boss.move_boss(rand_pos, TIME).finished
	await Boss.create_waiter(AFTER_MOVE_WAIT).finished
	
	move_loop()




func _on_Boss_tree_exiting():
	stopped = true
