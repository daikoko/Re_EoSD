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
const A_LAYOUT_COLUMN_RANGE := 20.0
const A_LAYOUT_DISTANCE := 20.0
const A_FIRE_DURATION := 2.0
const A_BULLET_SPEED := 200
const A_SHOOTER_ROTATION_SPEED_MINIMUM := 30
const A_SHOOTER_ROTATION_SPEED_MAXIMUM := 360
var A_direction:int = 1

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
				GlobalShooter.KNIFE_WHITE
			])
		])
	]
	A2_bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_BLUE
			])
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
		phase = 0


func attack_a() -> void:
	Boss.custom_animation("AttackA")
	
	var bullets:Array[RowData_Column]
	if A_direction == 1: bullets = A1_bullets
	else: bullets = A2_bullets
	
	A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED_MINIMUM) * A_direction
	var RotationTween = A_Shooter.create_tween().set_ease(Tween.EASE_IN)
	RotationTween.tween_property(
		A_Shooter, 
		"rotation_speed",
		deg_to_rad(A_SHOOTER_ROTATION_SPEED_MAXIMUM) * A_direction,
		A_FIRE_DURATION
	)
	
	A_Shooter.fire_round(
		bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED
	)
	await A_Shooter.finished_round
	
	A_direction *= -1
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
