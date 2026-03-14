extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.RUMIA

const SOUND_PHASE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.4
const RAND_SEED    := 11111

var A_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column] = []
var A2_Bullets:Array[RowData_Column] = []
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 12
@export_subgroup("A1")
@export var A1_fire_count:int = 4
@export_subgroup("A2")
@export var A2_spawn_stack_count:int = 3
const A1_FIRE_DURATION := 1.0
const A1_BULLET_SPEED := 200.0
const A2_BULLET_SPEED := 250.0
const A2_SPAWN_STACK_SPEED := 40.0
var A_shooter_rotation_speed:float = 0

var B_Shooter:Shooter_Tween
var B_Bullets:Array[RowData_Bullet] = []
@export_group("Shooter B")
@export var B_layout_spawner_count:int = 12
@export var B_fire_count:int = 3
@export var B_tween_double:bool = false
const B_FIRE_DURATION := 0.6
const B_TWEEN_TIME := 4.0
const B_TWEEN_MAX_ROTATION := 20.0
const B_TWEEN_MIN_ROTATION := 0.0
const B_SHOOTER_ROTATION := -45.0

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.2
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
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawner_count
	)
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_RED
			])
		])
	]
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_YELLOW
			])
		])
	]
	A_shooter_rotation_speed = (360 / 2) / (A1_FIRE_DURATION)
	
	B_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(
			B_layout_spawner_count
		)
	)
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.BRIGHT_RED
		])
	]
	
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
	
	if phase < 3:
		attack_a()
		phase += 1
	else:
		attack_b()
		phase = 0


func attack_a() -> void:
	Boss.custom_animation("AttackA")
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.rotation_speed = deg_to_rad(A_shooter_rotation_speed)
	A_Shooter.fire_round(
		A1_Bullets, 
		A1_fire_count, A1_FIRE_DURATION,
		A1_BULLET_SPEED
	)
	await A_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	move()


func attack_b() -> void:
	Boss.custom_animation("AttackA")
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	B_Shooter.rotation_speed = deg_to_rad(B_SHOOTER_ROTATION)
	B_Shooter.fire_round_full(
		B_Bullets, 
		B_fire_count, B_FIRE_DURATION,
		0, 0,
		B_TWEEN_TIME, B_TWEEN_MAX_ROTATION, B_TWEEN_MIN_ROTATION
	)
	await B_Shooter.finished_round
	
	A_Shooter.rotation = GlobalPlayer.angle_to_player(Boss.position)
	A_Shooter.fire_round_stack(
		A2_Bullets, 
		1, 0, 
		A2_BULLET_SPEED, 0, 
		0, 0,
		A2_spawn_stack_count, A2_SPAWN_STACK_SPEED
	)
	await A_Shooter.finished_round
	
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
