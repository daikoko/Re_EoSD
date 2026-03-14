extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.PATCHOULI

const SOUND_PHASE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")

const HELPER_1 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper01.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.4
const RAND_SEED    := 8516

var A1_Shooter:Shooter_Laser
var A2_Shooter:Shooter_Laser
var A_lasers:RowData_Column
@export_group("Shooter A")
@export var A_layout_spawner_count = 7
@export var A_double:bool = false
const A_LAYOUT_DISTANCE := 80.0
const A_LASER_DURATION := 1.4
const A_SHOOTER_ROTATION_SPEED := 16.0
const A_SHOOTER_DELAY := 1.0
var A_direction:int = 1

var B_Shooter:Node2D
var B_bullets:Array[RowData_Column]
@export_group("Shooter B")
@export var B_layout_spawner_count = 7
@export var B_fire_count = 120
const B_LAYOUT_DISTANCE := 120.0
const B_FIRE_DURATION := 2.6
const B_BULLET_SPEED = 200
const B_BULLET_SPEED_RANGE := 40.0
const B_SHOOTER_ROTATION_SPEED := 30.0
const B_MOVE_DELAY := 0.1

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.1
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
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	A1_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			A_layout_spawner_count, 
			1, 360, 360, 
			A_LAYOUT_DISTANCE)
	)
	A2_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(
			A_layout_spawner_count, 
			1, 360, 360, 
			A_LAYOUT_DISTANCE)
	)
	A_lasers = RowData_Column.new([
		ColumnData_Laser.new([
			LaserData.new(10.0, LaserData.COLOR.BLUE)
		])
	])
	Boss.add_child(A1_Shooter)
	Boss.add_child(A2_Shooter)
	
	B_Shooter = HELPER_1.instantiate()
	B_Shooter.set_shooters(
		B_layout_spawner_count, 
		B_LAYOUT_DISTANCE,
		RNG
	)
	B_bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_MAGENTA
			])
		])
	]
	Boss.add_child(B_Shooter)
	
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
	A1_Shooter.disable()
	A2_Shooter.disable()
	B_Shooter.queue_free()
	
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
		move_loop()
		phase = 0


func attack_a():
	Boss.custom_animation("AttackA")
	A1_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED) * A_direction
	A2_Shooter.rotation_speed = -deg_to_rad(A_SHOOTER_ROTATION_SPEED) * A_direction
	
	A1_Shooter.fire_round(
		A_lasers,
		A_LASER_DURATION
	)
	
	if A_double:
		await Boss.create_waiter(A_SHOOTER_DELAY).finished
		
		A2_Shooter.fire_round(
			A_lasers,
			A_LASER_DURATION
		)
		await A2_Shooter.finished_round
	
	else:
		await A1_Shooter.finished_round
	
	if stopped:
		return
	
	A_direction *= -1
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	next_phase()


func attack_b():
	B_Shooter.rotation_speed = - deg_to_rad(B_SHOOTER_ROTATION_SPEED) * A_direction
	B_Shooter.fire_round(
		B_bullets, 
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE
	)


func move_loop():
	await Boss.create_waiter(B_MOVE_DELAY).finished
	
	for i in 3:
		if stopped: return
		
		var rand_pos = GlobalStage.random_position(
			BOUND_RIGHT, BOUND_LEFT, BOUND_TOP, BOUND_BOTTOM, 
			Boss.position, DISTANCE, RNG
		)
		
		await Boss.move_boss(rand_pos, TIME).finished
		await Boss.create_waiter(AFTER_MOVE_WAIT).finished
	
	next_phase()




func _on_Boss_tree_exiting():
	stopped = true
