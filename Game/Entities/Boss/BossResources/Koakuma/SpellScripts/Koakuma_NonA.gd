extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.KOAKUMA

const SOUND_PHASE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 48577

var A_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column] = []
var A2_Bullets:Array[RowData_Column] = []
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 8
@export var A_fire_count:int = 16
const A_FIRE_DURATION := 1.2
const A_BULLET_SPEED := 240
const A_SHOOTER_ROTATION_SPEED:float = 90

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.2
const AFTER_ATTACK_WAIT := 0.1
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
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawner_count,
	)
	A_Shooter.RNG = RNG
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.MEDIUM_MAGENTA,
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.MEDIUM_MAGENTA,
				GlobalShooter.BRIGHT_BLUE
			])
		])
	]
	Boss.add_child(A_Shooter)
	
	return PREPARE_WAIT


func start() -> void:
	if show_background:
		SpellBackground.fade_in()
	
	await GlobalStage.create_timer_short(Boss, START_WAIT).timeout
	
	stopped = false
	non_started.emit()
	Boss.enable()
	
	next_phase()


func stop() -> void:
	stopped = true
	Boss.reset_waiters()
	A_Shooter.disable()
	
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
	elif phase == 1:
		attack_b()
		phase = 0


func attack_a() -> void:
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.rotation_speed = (
		deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	)
	A_Shooter.fire_round_stack(
		A1_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
	)
	await A_Shooter.finished_round
	
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	move()


func attack_b() -> void:
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.rotation_speed = (
		-deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	)
	A_Shooter.fire_round_stack(
		A2_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
	)
	await A_Shooter.finished_round
	
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
