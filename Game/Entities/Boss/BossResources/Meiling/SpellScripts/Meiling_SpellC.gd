extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.MEILING
const SPELL_ID := 3

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Meiling/Sprite/SpellPortrait_Meiling.tres")

const BOUND_RIGHT  := 620
const BOUND_LEFT   := 30
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 250
const TIME         := 0.6
const RAND_SEED := 97681

var A1_Shooter:Shooter_Basic
var A2_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 4
@export var A_fire_count:int = 24
const A_LAYOUT_DISTANCE := 20.0
const A_FIRE_DURATION := 2.8
const A_BULLET_SPEED := 180
const A_SHOOTER_ROTATION_SPEED := 60.0
const A_SHOOTER_ROTATION_SPEED_DRIFT := 0

var B_Shooter:Shooter_Tween
var B_Bullets:Array[RowData_Bullet] = []
@export_group("Shooter B")
@export var B_layout_spawner_count = 8
@export var B_fire_count = 6
const B_LAYOUT_DISTANCE := 30.0
const B_FIRE_DURATION := 2.4
const B_TWEEN_TIME = 8.0
const B_TWEEN_ROTATION_MAX = 8
const B_TWEEN_ROTATION_MIN = 0
const B_SHOOTER_ROTATION_SPEED := -60.0

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.2
const AFTER_ATTACK_WAIT := 0.4
const AFTER_MOVE_WAIT   := 0.4
const AFTER_EVENT_WAIT  := 0.8

var Boss:BossObject
var SpellBackground:Background
var MoveTween:Tween

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
		1, 360, 360, 
		A_LAYOUT_DISTANCE
	)
	A2_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawner_count, 
		1, 360, 360, 
		A_LAYOUT_DISTANCE
	)
	var A_bullets_base = [
		GlobalShooter.SEED_RED,
		GlobalShooter.SEED_YELLOW,
		GlobalShooter.SEED_GREEN,
		GlobalShooter.SEED_CYAN,
		GlobalShooter.SEED_BLUE,
		GlobalShooter.SEED_MAGENTA,
	]
	var interval = floori(A_fire_count / 6)
	for i in A_fire_count:
		var num = floori(i / interval)
		A_Bullets.append(
			RowData_Column.new([
				ColumnData_Bullet.new([
					A_bullets_base[num]
				])
			])
		)
	Boss.add_child(A1_Shooter)
	Boss.add_child(A2_Shooter)
	
	B_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(B_layout_spawner_count)
	)
	B_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.BRIGHT_YELLOW
		])
	]
	Boss.add_child(B_Shooter)
	
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
	
	await GlobalStage.create_timer_short(Boss, START_WAIT).timeout
	
	Boss.return_animation()
	await GlobalStage.create_timer_short(Boss, AFTER_ATTACK_WAIT).timeout
	
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
		phase += 1
	else:
		move()
		phase = 0


func attack_a():
	Boss.custom_animation("AttackA")
	
	var rot = RNG.randf_range(0, TAU)
	A1_Shooter.rotation = rot
	A1_Shooter.rotation_speed = deg_to_rad(
		(A_SHOOTER_ROTATION_SPEED) +
		A_SHOOTER_ROTATION_SPEED_DRIFT
	)
	A1_Shooter.fire_round(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED
	)
	
	A2_Shooter.rotation = rot
	A2_Shooter.rotation_speed = deg_to_rad(
		(A_SHOOTER_ROTATION_SPEED * -1) +
		A_SHOOTER_ROTATION_SPEED_DRIFT
	)
	A2_Shooter.fire_round(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED
	)
	
	await A1_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	next_phase()


func attack_b() -> void:
	B_Shooter.rotation_speed = deg_to_rad(B_SHOOTER_ROTATION_SPEED)
	B_Shooter.fire_round_full(
		B_Bullets, 
		B_fire_count, B_FIRE_DURATION,
		0, 0,
		B_TWEEN_TIME, B_TWEEN_ROTATION_MAX, B_TWEEN_ROTATION_MIN,
		true
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
