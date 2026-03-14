extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.CIRNO

const SOUND_PHASE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")

var A_Shooter:Shooter_Arrow
var A_Bullets:Array[RowData_Column]
@export_group("Shooter A")
@export var A_layout_spawner_count:int = 4
@export var A_fire_count:int = 4
const A_ARROW_SIZE := 3
const A_ARROW_LENGTH := 120.0
const A_ARROW_WIDTH := 120.0
const A_ARROW_DISPLACEMENT := 250.0
const A_FIRE_DURATION := 0.6
const A_BULLET_SPEED := 200
const A_SHOOTER_ROTATION_SPEED := 90.0
var A_phase:int = 0

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
@export_group("Shooter B")
@export var B_layout_column_count:int = 2
@export var B_fire_count:int = 8
const B_LAYOUT_SPAWNER_COUNT:int = 8
const B_LAYOUT_COLUMN_RANGE := 60.0
const B_FIRE_DURATION := 0.6
const B_BULLET_SPEED := 200
const B_BULLET_SPEED_RANGE := 75.0
const B_SHOOTER_ROTATION_SPEED := -360.0
var B_phase:int = 0

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 84416

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
	
	A_Shooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(A_layout_spawner_count),
		A_ARROW_SIZE, A_ARROW_LENGTH, A_ARROW_WIDTH, 
		A_ARROW_DISPLACEMENT,
		false
	)
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_BLUE
			])
		])
	]
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_LAYOUT_SPAWNER_COUNT, 
		B_layout_column_count, B_LAYOUT_COLUMN_RANGE, 360,
		GlobalShooter.STANDARD_START, 
		true, 
		RNG
	)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.STONE_CYAN
			])
		])
	]
	Boss.add_child(B_Shooter)
	
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
	
	if phase == 0:
		attack_a()
		phase = 0


func attack_a() -> void:
	Boss.custom_animation("AttackA")
	
	if A_phase == 0:
		A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED)
		A_phase += 1
	else:
		A_Shooter.rotation_speed = deg_to_rad(-A_SHOOTER_ROTATION_SPEED)
		A_phase = 0
	A_Shooter.fire_round(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED
	)
	await A_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	attack_b()
	move()


func attack_b() -> void:
	if B_phase == 0:
		B_Shooter.rotation_speed = deg_to_rad(B_SHOOTER_ROTATION_SPEED)
		B_phase += 1
	else:
		B_Shooter.rotation_speed = deg_to_rad(-B_SHOOTER_ROTATION_SPEED)
		B_phase = 0
	B_Shooter.fire_round_stack(
		B_Bullets, 
		B_fire_count, B_FIRE_DURATION, 
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE
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
