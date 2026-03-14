extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.SAKUYA

const SOUND_PHASE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.4
const RAND_SEED    := 15581

var A_Shooter:Shooter_Basic
var A1_bullets:Array[RowData_Column]
var A2_bullets:Array[RowData_Column]
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 2
@export var A_layout_column_count:int = 8
@export var A_fire_count:int = 30
@export var A_bullet_speed_curve:Curve
const A_LAYOUT_COLUMN_RANGE := 20.0
const A_LAYOUT_DISTANCE := 20.0
const A_FIRE_DURATION := 1.4
const A_SHOOTER_ROTATION_SPEED := 60.0
var A_direction:int = 1

var B_Shooter:Shooter_Basic
var B_bullets:Array[RowData_Column]
@export_group("Shooter B")
@export var B_layout_spawner_count:int = 2
@export var B_fire_count:int = 20
const B_LAYOUT_SHOT_RANGE := 30.0
const B_LAYOUT_DISTANCE := 20.0
const B_FIRE_DURATION := 0.4
const B_BULLET_SPEED := 200
const B_SHOOTER_ROTATION_ARC := 120.0
var B_direction:int = 1

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.2
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
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawner_count,
		A_layout_column_count, A_LAYOUT_COLUMN_RANGE, 360, 
		A_LAYOUT_DISTANCE
	)
	Boss.add_child(A_Shooter)
	A1_bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_BLUE
			])
		])
	]
	A2_bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_WHITE
			])
		])
	]
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count, 
		1, 360, B_LAYOUT_SHOT_RANGE, 
		B_LAYOUT_DISTANCE
	)
	Boss.add_child(B_Shooter)
	B_bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_RED
			])
		])
	]
	
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




func next_phase() -> void:
	if stopped:
		return
	
	if phase == 0:
		attack_a()
		phase += 1
	else:
		attack_b()
		move()
		phase = 0


func attack_a() -> void:
	Boss.custom_animation("AttackA")
	
	A_Shooter.rotation_speed = (
		A_direction * deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	)
	A_Shooter.fire_round_curve(
		A1_bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_bullet_speed_curve
	)
	await A_Shooter.finished_round
	
	A_Shooter.rotation_speed = (
		-A_direction * deg_to_rad(A_SHOOTER_ROTATION_SPEED)
	)
	A_Shooter.fire_round_curve(
		A2_bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_bullet_speed_curve
	)
	await A_Shooter.finished_round
	
	A_direction *= -1
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	next_phase()


func attack_b() -> void:
	var angle_to_player = GlobalPlayer.angle_to_player(B_Shooter.global_position)
	B_Shooter.rotation = (
		angle_to_player + 
		(B_direction * deg_to_rad(B_SHOOTER_ROTATION_ARC / 2))
	)
	B_Shooter.rotation_speed = (
		-B_direction * deg_to_rad(B_SHOOTER_ROTATION_ARC / B_FIRE_DURATION)
	)
	B_Shooter.fire_round(
		B_bullets, 
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED
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
