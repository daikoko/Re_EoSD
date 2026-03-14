extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.RUMIA
const SPELL_ID := 2

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
const RAND_SEED    := 15917

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column] = []
@export_group("Shooter A")
@export var A_fire_count:int = 5
@export var A_spawn_stack_count:int = 2
const A_FIRE_DURATION := 0.4
const A_BULLET_SPEED := 240
const A_SPAWN_STACK_SPEED := 40.0
const A_SHOOTER_ROTATION_ARC_ANGLE := 60.0
const A_SHOOTER_ROTATION_OFFSET := 20
const A_SHOOTER_ROUND_COUNT := 4
var A_shooter_rotation_speed:float

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column] = []
@export_group("Shooter B")
@export var B_fire_count:int = 9
@export var B_spawn_stack_count:int = 3
const B_FIRE_DURATION := 0.4
const B_BULLET_SPEED := 260
const B_SPAWN_STACK_SPEED := 20.0
const B_SHOOTER_ROTATION_ARC_ANGLE := 90
const B_SHOOTER_DELAY_TIME := 1.2
var B_DelayTimer:Timer
var B_shooter_rotation_speed:float
var B_direction:int = 1

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
	
	A_Shooter = GlobalShooter.create_basic_shooter(1)
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_CYAN
			])
		])
	]
	A_shooter_rotation_speed = (
		A_SHOOTER_ROTATION_ARC_ANGLE / A_FIRE_DURATION
	)
	
	B_Shooter = GlobalShooter.create_basic_shooter(1)
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_BLUE
			])
		])
	]
	B_DelayTimer = GlobalStage.create_timer(
		B_Shooter, 
		B_SHOOTER_DELAY_TIME, true
	)
	B_shooter_rotation_speed = (
		B_SHOOTER_ROTATION_ARC_ANGLE / B_FIRE_DURATION
	)
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	return 1.4


func start() -> void:
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	Boss.custom_animation("AttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background:
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
		attack_b()
		phase = 0


func attack_a() -> void:
	var direction = 1
	var base_angle = GlobalPlayer.angle_to_player(Boss.position)
	for i in A_SHOOTER_ROUND_COUNT:
		A_Shooter.rotation = (
			base_angle - 
			direction * deg_to_rad(A_SHOOTER_ROTATION_OFFSET)
		)
		A_Shooter.rotation_speed = (
			direction * deg_to_rad(A_shooter_rotation_speed)
		)
		
		A_Shooter.fire_round_stack(
			A_Bullets, 
			A_fire_count, A_FIRE_DURATION,
			A_BULLET_SPEED, 0, 
			0, 0,
			A_spawn_stack_count, A_SPAWN_STACK_SPEED
		)
		await A_Shooter.finished_round
		
		direction *= -1


func attack_b() -> void:
	Boss.custom_animation("AttackA")
	
	B_DelayTimer.start()
	await B_DelayTimer.timeout
	
	B_Shooter.rotation = (
		GlobalPlayer.angle_to_player(Boss.position) - 
		B_direction * deg_to_rad(B_SHOOTER_ROTATION_ARC_ANGLE/2)
	)
	B_Shooter.rotation_speed = (
		B_direction * deg_to_rad(B_shooter_rotation_speed)
	)
	
	B_Shooter.fire_round_stack(
		B_Bullets, 
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, 0, 
		0, 0,
		B_spawn_stack_count, B_SPAWN_STACK_SPEED
	)
	await B_Shooter.finished_round
	
	B_direction *= -1
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
