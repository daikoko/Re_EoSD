extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.REMILIA
const SPELL_ID := 8

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Remilia/Sprite/SpellPortrait_Remilia.tres")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 495227

@export_group("Special")
@export var special_animation:bool = false

var A1_Shooter:Shooter_Arrow
var A1_Bullets:RowData_Column
var A2_Shooter:Shooter_Basic
var A2_Bullets:RowData_Column
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 4
@export var A_fire_time:float = 0.4
const A_ARROW_SIZE := 5
const A_ARROW_LENGTH := 120.0
const A_ARROW_WIDTH := 80.0
const A_ARROW_DISPLACEMENT := 250.0
const A_ARROW_FILL := true
const A_BULLET_SPEED := 200

var B1_Shooter:Shooter_Laser
var B2_Shooter:Shooter_Laser
var B_lasers:RowData_Column
@export_group("Shooter B")
@export var B_layout_spawner_count = 7
@export var B_double:bool = false
const B_LAYOUT_DISTANCE := 80.0
const B_LASER_DURATION := 1.4
const B_SHOOTER_ROTATION_SPEED := 8.0
const B_SHOOTER_DELAY := 1.0
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
	
	A1_Shooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(A_layout_spawner_count),
		A_ARROW_SIZE, A_ARROW_LENGTH, A_ARROW_WIDTH, 
		A_ARROW_DISPLACEMENT,
		true
	)
	A1_Bullets = RowData_Column.new(
		[
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		]
	)
	A1_Shooter.rotation = RNG.randi_range(0, TAU)
	Boss.add_child(A1_Shooter)
	
	A2_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A2_Bullets = RowData_Column.new(
		[
			ColumnData_Bullet.new([
				GlobalShooter.LARGE_RED
			])
		]
	)
	Boss.add_child(A2_Shooter)
	
	B1_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			B_layout_spawner_count, 
			1, 360, 360, 
			B_LAYOUT_DISTANCE)
	)
	B2_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			B_layout_spawner_count, 
			1, 360, 360, 
			B_LAYOUT_DISTANCE)
	)
	B_lasers = RowData_Column.new([
		ColumnData_Laser.new([
			LaserData.new(10.0, LaserData.COLOR.RED)
		])
	])
	Boss.add_child(B1_Shooter)
	Boss.add_child(B2_Shooter)
	
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
	
	attack_a_loop()
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
	
	attack_b()


func attack_a_loop():
	while stopped == false:
		A1_Shooter.rotation += TAU / A_layout_spawner_count / 2
		A1_Shooter.fire_row(
			A1_Bullets, 
			A_BULLET_SPEED
		)
		
		await Boss.create_waiter(0.2).finished
		
		A2_Shooter.rotation = A1_Shooter.rotation
		A2_Shooter.fire_row(
			A2_Bullets, 
			A_BULLET_SPEED * 0.6
		)
		
		await Boss.create_waiter(A_fire_time).finished


func attack_b():
	Boss.custom_animation("AttackA")
	B1_Shooter.rotation_speed = deg_to_rad(B_SHOOTER_ROTATION_SPEED) * B_direction
	B2_Shooter.rotation_speed = -deg_to_rad(B_SHOOTER_ROTATION_SPEED) * B_direction
	
	B1_Shooter.fire_round(
		B_lasers,
		B_LASER_DURATION
	)
	
	if B_double:
		await Boss.create_waiter(B_SHOOTER_DELAY).finished
		
		B2_Shooter.fire_round(
			B_lasers,
			B_LASER_DURATION
		)
		await B2_Shooter.finished_round
	
	else:
		await B1_Shooter.finished_round
	
	if stopped:
		return
	
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
