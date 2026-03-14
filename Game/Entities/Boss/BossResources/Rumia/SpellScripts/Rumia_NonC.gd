extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.RUMIA

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 240
const TIME         := 0.4
const RAND_SEED    := 158132

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Shooter_Linear
var A_Bullets:Array[RowData_Column] = []
@export_group("Shooter A")
@export var A_layout_spawner_count:int
@export var A_layout_column_count:int
@export var A_spawn_stack_count:int
@export var A_fire_count:int
const A_LAYOUT_COLUMN_RANGE := 30.0
const A_BULLET_SPEED := 400.0
const A_BULLET_SPEED_RANGE := 40.0
const A_SPAWN_STACK_SPEED := -30
const A_FIRE_DURATION := 0.8
const A_SHOOTER_ROTATION_SPEED := 420.0
var A_direction:int = 1

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column] = []
@export_group("Shooter B")
@export var B_layout_spawner_count:int
@export var B_spawn_stack_count:int
@export var B_fire_count:int
const B_BULLET_SPEED := 360.0
const B_SPAWN_STACK_SPEED := -20
const B_FIRE_DURATION := 0.8

var C_Shooter:Shooter_Basic
var C_Bullets:Array[RowData_Column] = []
@export_group("Shooter C")
@export var C_layout_spawner_count:int
@export var C_fire_count:int
const C_BULLET_SPEED := 320.0
const C_SHOOTER_ROTATION_SPEED := 270.0
const C_FIRE_DURATION := 0.8

var D_Shooter:Shooter_Linear
var D_Bullets:Array[RowData_Column] = []
@export_group("Shooter D")
@export var D_fire_count:int
@export var D_spawn_stack_count:int
const D_LAYOUT_SPAWNER_COUNT = 1
const D_LAYOUT_DISTANCE := 120.0
const D_FIRE_DURATION := 0.4
const D_BULLET_SPEED := 0.0
const D_LINEAR_DELAY := 0.4
const D_LINEAR_TIME := 1.2
const D_LINEAR_SPEED_CHANGE := 520.0
const D_SPAWN_STACK_SPEED := -80.0
const D_SHOOTER_ROUNT_COUNT := 8
const D_SHOOTER_ROTATION_SPEED := 300.0
var D_direction:int = -1

var E_Shooter:Shooter_Tween
var E_Bullets:Array[RowData_Bullet] = []
@export_group("Shooter E")
@export var E_layout_spawner_count:int
@export var E_shooter_round_count:int
const E_FIRE_COUNT := 2
const E_FIRE_DURATION := 0.2
const E_TWEEN_TIME := 6.0
const E_TWEEN_MAX_ROTATION := 280.0
const E_TWEEN_MIN_ROTATION := 180.0
const E_TWEEN_FLIP_INTERVAL := 1
const E_SHOOTER_ROUND_DURATION := 3.0

var F1_Shooter:Shooter_Laser
var F2_Shooter:Shooter_Laser
var F_lasers:RowData_Column
@export_group("Shooter F")
@export var F_layout_spawner_count:int = 7
const F_LAYOUT_DISTANCE := 80.0
const F_LASER_DELAY := 0.6
const F_LASER_DURATION := 1.2
const F_SHOOTER_WAIT := 1.2

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.2
const START_WAIT_ADD    := 0.8
const AFTER_ATTACK_WAIT := 0.4
const AFTER_MOVE_WAIT   := 0.4
const AFTER_EVENT_WAIT  := 0.8

var Boss:BossObject
var SpellBackground:Background

var phase:int = 0




func prepare(EventHandler:Control, Boss_Dict:Dictionary) -> float:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	Boss = Boss_Dict["boss"]
	Boss.tree_exiting.connect(_on_Boss_tree_exiting)
	SpellBackground = Boss_Dict["background"]
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	A_Shooter = GlobalShooter.create_linear_shooter(
		A_layout_spawner_count,
		A_layout_column_count, A_LAYOUT_COLUMN_RANGE,
	)
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(B_layout_spawner_count)
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_YELLOW
			])
		])
	]
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B_Shooter.rotation_speed = TAU
	
	C_Shooter = GlobalShooter.create_basic_shooter(C_layout_spawner_count)
	C_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.LARGE_YELLOW
			])
		])
	]
	C_Shooter.RNG = RNG
	Boss.add_child(C_Shooter)
	
	D_Shooter = GlobalShooter.create_linear_shooter(
		D_LAYOUT_SPAWNER_COUNT,
		1, 360,
		360,
		D_LAYOUT_DISTANCE
	)
	D_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	D_Shooter.RNG = RNG
	Boss.add_child(D_Shooter)
	
	E_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(E_layout_spawner_count)
	)
	E_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.BRIGHT_YELLOW
		])
	]
	E_Shooter.RNG = RNG
	Boss.add_child(E_Shooter)
	
	F1_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			F_layout_spawner_count, 
			1, 360, 360, 
			F_LAYOUT_DISTANCE)
	)
	F2_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			F_layout_spawner_count, 
			1, 360, 360, 
			F_LAYOUT_DISTANCE)
	)
	F_lasers = RowData_Column.new([
		ColumnData_Laser.new([
			LaserData.new(10.0, LaserData.COLOR.RED)
		])
	])
	Boss.add_child(F1_Shooter)
	Boss.add_child(F2_Shooter)
	
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
	
	next_phase()


func stop() -> void:
	stopped = true
	Boss.reset_waiters()
	A_Shooter.disable()
	B_Shooter.disable()
	C_Shooter.disable()
	D_Shooter.disable()
	E_Shooter.disable()
	F1_Shooter.disable()
	F2_Shooter.disable()
	
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
	
	
	if phase < 3:
		attack_a()
		attack_b()
		attack_c()
		phase += 1
	
	else:
		attack_d()
		attack_e()
		attack_f()
		phase = 0


func attack_a() -> void:
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED) * A_direction
	
	Boss.custom_animation("SwordAttackA")
	
	A_Shooter.fire_round_stack(
		A_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, A_BULLET_SPEED_RANGE,
		0, 0,
		A_spawn_stack_count, A_SPAWN_STACK_SPEED
	)
	await A_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	A_direction *= -1
	
	move()


func attack_b() -> void:
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	B_Shooter.rotation_speed = (TAU / B_layout_spawner_count) / (B_FIRE_DURATION / B_fire_count) / 2
	
	B_Shooter.fire_round_stack(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, 0,
		0, 0,
		B_spawn_stack_count, B_SPAWN_STACK_SPEED
	)


func attack_c() -> void:
	C_Shooter.rotation = RNG.randf_range(0, TAU)
	C_Shooter.rotation_speed = (TAU / C_layout_spawner_count) / (C_FIRE_DURATION / C_fire_count) / 2
	C_Shooter.fire_round_stack(
		C_Bullets,
		C_fire_count, C_FIRE_DURATION,
		C_BULLET_SPEED
	)


func attack_d() -> void:
	Boss.custom_animation("SwordAttackA")
	
	for _i in D_SHOOTER_ROUNT_COUNT:
		D_Shooter.rotation = RNG.randf_range(0, TAU)
		D_Shooter.rotation_speed = deg_to_rad(D_SHOOTER_ROTATION_SPEED) * D_direction
		
		for _j in D_fire_count:
			var linear_speed_change = D_LINEAR_SPEED_CHANGE
			
			for _k in D_spawn_stack_count:
				D_Shooter.fire_row(
					D_Bullets[0],
					D_BULLET_SPEED, 0,
					0, 0,
					D_LINEAR_DELAY,
					D_LINEAR_TIME,
					linear_speed_change
				)
				
				linear_speed_change -= D_SPAWN_STACK_SPEED
			
			await Boss.create_waiter(D_FIRE_DURATION / D_fire_count).finished
		
		D_direction *= -1
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	D_direction *= -1
	
	move()


func attack_e() -> void:
	for _i in E_shooter_round_count:
		E_Shooter.rotation = RNG.randf_range(0, TAU)
		E_Shooter.fire_round_full(
			E_Bullets,
			E_FIRE_COUNT, E_FIRE_DURATION,
			0, 0, 
			E_TWEEN_TIME, 
			deg_to_rad(E_TWEEN_MAX_ROTATION), 
			deg_to_rad(E_TWEEN_MIN_ROTATION),
			false,
			[],
			E_TWEEN_FLIP_INTERVAL
		)
		
		await Boss.create_waiter((E_SHOOTER_ROUND_DURATION - (E_FIRE_DURATION * E_FIRE_COUNT)) / E_shooter_round_count).finished


func attack_f() -> void:
	await Boss.create_waiter(F_SHOOTER_WAIT).finished
	
	var random_rotation = RNG.randf_range(0, TAU)
	F1_Shooter.rotation = random_rotation
	F2_Shooter.rotation = random_rotation
	
	F1_Shooter.fire_round(
		F_lasers,
		F_LASER_DURATION,
		F_LASER_DELAY
	)
	F2_Shooter.fire_round(
		F_lasers,
		F_LASER_DURATION,
		F_LASER_DELAY
	)
	await Boss.create_waiter(F_LASER_DELAY).finished
	
	var ShotTween = F1_Shooter.create_tween().set_parallel()
	ShotTween.tween_property(
		F1_Shooter, 
		"rotation", 
		random_rotation + ((TAU / F_layout_spawner_count) * 0.5 * 0.8), 
		F_LASER_DURATION
	)
	ShotTween.tween_property(
		F2_Shooter, 
		"rotation", 
		random_rotation - ((TAU / F_layout_spawner_count) * 0.5 * 0.8), 
		F_LASER_DURATION
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
