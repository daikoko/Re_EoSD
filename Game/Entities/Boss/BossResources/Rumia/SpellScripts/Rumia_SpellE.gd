extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.RUMIA
const SPELL_ID := 5

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Rumia/Sprite/SpellPortrait_RumiaPhantasm.tres")
const HELPER_02 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper02.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.4
const RAND_SEED    := 15917

@export_group("Special")
@export var special_animation:bool = false

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.4
const AFTER_ATTACK_WAIT := 0.4
const AFTER_MOVE_WAIT   := 0.4
const AFTER_EVENT_WAIT  := 0.8

var A_Shooter:Node2D
@export_group("A_Shooter")
@export var A_shooter_count:int 
@export var A_fire_count:int
const A_FIRE_DURATION := 1.0

var B_Shooter:Shooter_Tween
var B_Bullets:Array[RowData_Bullet] = []
@export_group("Shooter B")
@export var B_layout_spawner_count:int
const B_FIRE_COUNT := 4
const B_FIRE_DURATION := 0.5
const B_TWEEN_TIME := 6.0
const B_TWEEN_MAX_ROTATION := 260.0
const B_TWEEN_MIN_ROTATION := 200.0
const B_TWEEN_FLIP_INTERVAL := 1
const B_SHOOTER_ROUND_WAIT_TIME := 1.2

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
	
	A_Shooter = HELPER_02.instantiate()
	A_Shooter.RNG = RNG
	A_Shooter.build(A_shooter_count)
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(B_layout_spawner_count)
	)
	B_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.BRIGHT_RED
		])
	]
	B_Shooter.RNG = RNG
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
	Boss.custom_animation("SwordAttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(START_WAIT).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	attack_loop_a()
	attack_loop_b()
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
		phase = 0


func attack_loop_a():
	while stopped == false:
		A_Shooter.fire(
			A_fire_count,
			A_FIRE_DURATION
		)
		await A_Shooter.shooter_finished


func attack_loop_b() -> void:
	while stopped == false:
		B_Shooter.rotation = RNG.randf_range(0, TAU)
		B_Shooter.rotation_speed = TAU
		B_Shooter.fire_round_full(
			B_Bullets,
			B_FIRE_COUNT, B_FIRE_DURATION,
			0, 0, 
			B_TWEEN_TIME, 
			deg_to_rad(B_TWEEN_MAX_ROTATION), 
			deg_to_rad(B_TWEEN_MIN_ROTATION),
			false,
			[],
			B_TWEEN_FLIP_INTERVAL
		)
		
		await Boss.create_waiter(B_SHOOTER_ROUND_WAIT_TIME).finished


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
