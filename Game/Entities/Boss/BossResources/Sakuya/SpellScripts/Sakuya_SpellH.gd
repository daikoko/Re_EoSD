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
const TIME         := 1.0
const RAND_SEED    := 446658

var A1_Shooter:Shooter_Basic
var A2_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column]
var A2_Bullets:Array[RowData_Column]
@export_group("A Shooter")
@export_subgroup("A1")
@export var A1_layout_spawner_count:int = 1
@export var A1_fire_count:int = 1
const A1_FIRE_DURATION := TIME
const A1_BULLET_SPEED := 160
const A1_BULLET_SPEED_RANGE := 40  
@export_subgroup("A2")
@export var A2_layout_spawner_count:int = 1
@export var A2_fire_count:int = 1
const A2_FIRE_DURATION := TIME
const A2_BULLET_SPEED := 220
const A2_BULLET_SPEED_RANGE := 40  
const A2_SHOOTER_ROTATION_SPEED := 60
var A_direction:int = 1

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
		A1_layout_spawner_count
	)
	A1_Shooter.RNG = RNG
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.MEDIUM_BLUE
			])
		])
	]
	Boss.add_child(A1_Shooter)
	
	A2_Shooter = GlobalShooter.create_basic_shooter(
		A2_layout_spawner_count
	)
	A2_Shooter.RNG = RNG
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_WHITE
			])
		])
	]
	Boss.add_child(A2_Shooter)
	
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
		move()
		phase = 0


func attack_a():
	A1_Shooter.rotation_random = true
	A1_Shooter.fire_round(
		A1_Bullets, 
		A1_fire_count, A1_FIRE_DURATION,
		A1_BULLET_SPEED, A1_BULLET_SPEED_RANGE
	)
	
	A2_Shooter.rotation_speed = deg_to_rad(A2_SHOOTER_ROTATION_SPEED) * A_direction
	A2_Shooter.fire_round(
		A2_Bullets, 
		A2_fire_count, A2_FIRE_DURATION,
		A2_BULLET_SPEED, A2_BULLET_SPEED_RANGE
	)
	
	await A1_Shooter.finished_round
	
	A_direction *= -1
	
	next_phase()


func move() -> void:
	var rand_pos = GlobalStage.random_position(
		BOUND_RIGHT, BOUND_LEFT, BOUND_TOP, BOUND_BOTTOM, 
		Boss.position, DISTANCE, RNG
	)
	
	Boss.move_boss(rand_pos, TIME)



func _on_Boss_tree_exiting():
	stopped = true
