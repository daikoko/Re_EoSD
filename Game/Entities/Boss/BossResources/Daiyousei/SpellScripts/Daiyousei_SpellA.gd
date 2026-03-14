extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.DAIYOUSEI
const SPELL_ID := 1

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Daiyousei/Sprite/SpellPortrait_Daiyousei.tres")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 88462

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column] = []
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 12
@export var A_fire_count:int = 6
const A_FIRE_DURATION := 0.6
const A_BULLET_SPEED := 200
const A_SHOOTER_ROTATION_SPEED := 120

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column] = []
@export_group("Shooter B")
@export var B_layout_spawner_count:int = 7
@export var B_fire_count:int = 12
const B_LAYOUT_COLUMN_RANGE := 60
const B_FIRE_DURATION := 0.4
const B_BULLET_SPEED := 260
const B_SHOOTER_DELAY_TIME := 0.6

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.2
const AFTER_ATTACK_WAIT := 0.1
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
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	A_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A_Shooter.RNG = RNG
	A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KUNAI_GREEN
			])
		])
	]
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count,
		1, B_LAYOUT_COLUMN_RANGE)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KUNAI_BLUE
			])
		])
	]
	Boss.add_child(B_Shooter)
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return PREPARE_WAIT


func start() -> void:
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await GlobalStage.create_timer_short(Boss, START_WAIT).timeout
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	next_phase()


func stop() -> void:
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
		attack_a(true)
		phase += 1
	elif phase == 1:
		attack_a()
		attack_b()
		phase = 0


func attack_a(move:bool=false) -> void:
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.fire_round(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED
	)
	await A_Shooter.finished_round
	
	if move:
		move()


func attack_b() -> void:
	await Boss.create_waiter(B_SHOOTER_DELAY_TIME).finished
	
	B_Shooter.rotation = GlobalPlayer.angle_to_player(B_Shooter.global_position)
	B_Shooter.fire_round(
		B_Bullets, 
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED
	)
	await B_Shooter.finished_round
	
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
