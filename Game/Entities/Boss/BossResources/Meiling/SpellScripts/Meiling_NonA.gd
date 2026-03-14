extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.MEILING

const SOUND_PHASE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.4
const RAND_SEED    := 46825

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 8
@export var A_fire_count:int = 32
const A_FIRE_DURATION := 1.2
const A_BULLET_SPEED_CURVE := preload("res://Game/Entities/Boss/BossResources/Meiling/SpellResources/Helper01.tres")
const A_SHOOTER_ROTATION_SPEED := 60.0
var A_direction:int = 1

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
@export_group("Shooter B")
@export var B_layout_spawner_count:int = 8
@export var B_fire_count:int = 8
const B_LAYOUT_SHOT_RANGE := 360
const B_FIRE_DURATION := 1.0
const B_BULLET_SPEED := 220
const B_BULLET_SPEED_RANGE := 100
const B_BULLET_GRAVITY := 2.0
const B_SHOOTER_ROTATION_SPEED := 180.0

var C_Shooter:Shooter_Basic
var C_Bullets:RowData_Column
@export_group("Shooter C")
@export var C_layout_spawner_count:int = 12
@export var C_fire_count:int = 4
const C_BULLET_SPEED := 160
const C_BULLET_SPEED_RANGE := 60

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.2
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
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawner_count, 1,
		 360, 360, 20
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
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count, 1, 
		360, B_LAYOUT_SHOT_RANGE, 20,
		true, RNG
	)
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_YELLOW
			])
		])
	]
	Boss.add_child(B_Shooter)
	B_Shooter.rotation_speed = deg_to_rad(B_SHOOTER_ROTATION_SPEED)
	B_Shooter.RNG = RNG
	
	C_Shooter = GlobalShooter.create_basic_shooter(
		C_layout_spawner_count, 1, 
		360, 360, 20
	)
	C_Bullets = RowData_Column.new([
		ColumnData_Bullet.new([
			GlobalShooter.SMALL_YELLOW
		])
	])
	Boss.add_child(C_Shooter)
	C_Shooter.RNG = RNG
	
	return PREPARE_WAIT


func start() -> void:
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
	
	Boss.reset_animation()
	Death.start(Boss.position)
	EventHandler.play_sound_boss(SOUND_PHASE)
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
	
	if phase == 0:
		attack_a()
		phase += 1
	else:
		attack_b()
		phase = 0


func attack_a() -> void:
	Boss.custom_animation("AttackA")
	A_Shooter.rotation_speed = (
		A_direction * deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	)
	
	A_Shooter.fire_round_curve(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED_CURVE
	)
	await A_Shooter.finished_round
	
	A_direction *= -1
	Boss.return_animation()
	
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	next_phase()


func attack_b() -> void:
	var rand_pos = GlobalStage.random_position(
		BOUND_RIGHT, BOUND_LEFT, BOUND_TOP, BOUND_BOTTOM, 
		Boss.position, DISTANCE, RNG
	)
	
	var B_direction = rand_pos.x - Boss.position.x
	if B_direction < 0:
		B_Shooter.rotation = deg_to_rad(-60)
	elif B_direction >= 0:
		B_Shooter.rotation = deg_to_rad(-120)
	B_Shooter.fire_round_gravity(
		B_Bullets, 
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE,
		0, 0,
		B_BULLET_GRAVITY
		
	)
	
	await Boss.move_boss(rand_pos, TIME).finished
	if !stopped:
		attack_c()


func attack_c() -> void:
	for i in C_fire_count:
		C_Shooter.rotation = RNG.randf_range(0, 360)
		C_Shooter.fire_row(
			C_Bullets,
			C_BULLET_SPEED, C_BULLET_SPEED_RANGE 
		)
	
	next_phase()


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
