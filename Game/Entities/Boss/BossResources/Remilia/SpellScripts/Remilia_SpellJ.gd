extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.REMILIA
const SPELL_ID := 10

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Remilia/Sprite/SpellPortrait_Remilia.tres")
const HELPER_21 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper21.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 495227

@export_group("Special")
@export var special_animation:bool = false

var A1_Shooter:Shooter_Basic
var A2_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
@export_group("A_Shooter")
@export var A_layout_spawner_count:int
@export var A_fire_count:int
const A_LAYOUT_SHOT_RANGE := 30.0
const A_FIRE_DURATION := 1.6
const A_BULLET_SPEED := 240
const A_SPAWN_STACK_COUNT := 2
const A_SPAWN_STACK_SPEED := -60
const A_SHOOTER_ROTATION := 120
const A_SHOOTER_FIRE_ARC := 180

var B_Shooter:Node2D

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
		A_layout_spawner_count,
		1, 360,
		A_LAYOUT_SHOT_RANGE
	)
	A2_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawner_count,
		1, 360,
		A_LAYOUT_SHOT_RANGE
	)
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	Boss.add_child(A1_Shooter)
	Boss.add_child(A2_Shooter)
	
	B_Shooter = HELPER_21.instantiate()
	Boss.add_child(B_Shooter)
	
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


func attack_a():
	Boss.custom_animation("AttackA")
	
	var angle = GlobalPlayer.angle_to_player(A1_Shooter.global_position)
	
	A1_Shooter.rotation = angle - deg_to_rad(A_SHOOTER_ROTATION)
	A1_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_FIRE_ARC / A_FIRE_DURATION)
	A1_Shooter.fire_round_stack(
		A_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
		0, 0,
		A_SPAWN_STACK_COUNT, A_SPAWN_STACK_SPEED
	)
	
	A2_Shooter.rotation = angle + deg_to_rad(A_SHOOTER_ROTATION)
	A2_Shooter.rotation_speed = -deg_to_rad(A_SHOOTER_FIRE_ARC / A_FIRE_DURATION)
	A2_Shooter.fire_round_stack(
		A_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
		0, 0,
		A_SPAWN_STACK_COUNT, A_SPAWN_STACK_SPEED
	)
	
	await A1_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	move()


func attack_b():
	B_Shooter.rotation = GlobalPlayer.angle_to_player(A1_Shooter.global_position)
	B_Shooter.fire()


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
