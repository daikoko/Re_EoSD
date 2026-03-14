extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.SAKUYA

const SOUND_PHASE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const HELPER_01 := preload("res://Game/Entities/Boss/BossResources/Sakuya/SpellResources/SakuyaHelper01.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.4
const RAND_SEED    := 4210

var A_Shooter:Node2D
var A1_Bullets:Array[RowData_Column]
var A2_Bullets:Array[RowData_Column]
var A3_Bullets:Array[RowData_Column]
enum A_ATTACK_SET{
	SET_1,
	SET_2,
	SET_3,
}
@export_group("Shooter A")
@export var A_attack_set:A_ATTACK_SET
@export var A_travel_distance_curve:Curve
const A_TRAVEL_DISTANCE_TIME := 2.0
const A_TRAVEL_DISTANCE_MINIMUM := 100
const A_TRAVEL_DISTANCE_MAXIMUM := 300
@export_subgroup("Set 1")
@export var A1_primary_layout_spawner_count:int = 2
@export var A1_primary_fire_count:int = 30
@export var A1_secondary_layout_spawner_count:int = 3
@export var A1_secondary_stack_count:int = 3
const A1_PRIMARY_LAYOUT_SHOT_RANGE:float = 120
const A1_PRIMARY_FIRE_DURATION:float = 1.2
const A1_SECONDARY_LAYOUT_SHOT_RANGE:float = 90
const A1_SECONDARY_BULLET_SPEED := 120
const A1_SECONDARY_BULLET_STACK_SPEED := 40
@export_subgroup("Set 2")
@export var A2_primary_layout_spawner_count:int = 2
@export var A2_primary_fire_count:int = 30
@export var A2_secondary_layout_spawner_count:int = 3
@export var A2_secondary_stack_count:int = 3
const A2_PRIMARY_LAYOUT_SHOT_RANGE:float = 360
const A2_PRIMARY_FIRE_DURATION:float = 0.8
const A2_SECONDARY_LAYOUT_SHOT_RANGE:float = 360
const A2_SECONDARY_BULLET_SPEED := 120
const A2_SECONDARY_BULLET_STACK_SPEED := 40
const A2_SHOOTER_ROTATION_SPEED:float = 90.0
@export_subgroup("Set 3")
@export var A3_primary_layout_spawner_count:int = 2
@export var A3_primary_fire_count:int = 30
@export var A3_secondary_layout_spawner_count:int = 3
@export var A3_secondary_stack_count:int = 3
const A3_PRIMARY_LAYOUT_SHOT_RANGE:float = 120
const A3_PRIMARY_FIRE_DURATION:float = 0.8
const A3_SECONDARY_LAYOUT_SHOT_RANGE:float = 360
const A3_SECONDARY_BULLET_SPEED := 120
const A3_SECONDARY_BULLET_STACK_SPEED := 40
var A_direction:int = 1

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
@export_group("Shooter B")
@export var B_layout_column_count:int = 4
@export var B_fire_count:int = 40
const B_LAYOUT_SPAWNER_COUNT:int = 2
const B_LAYOUT_COLUMN_RANGE:float = 30
const B_FIRE_DURATION:float = 2.0
const B_BULLET_SPEED:float = 240
const B_SHOOTER_ROTATION_SPEED:float = 60.0
const B_MOVE_WAIT:float = (B_FIRE_DURATION - TIME) / 2
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
	
	var A_primary_layout_spawner_count:int = 0
	var A_primary_layout_shot_range:int = 0
	if A_attack_set == A_ATTACK_SET.SET_1:
		A_primary_layout_spawner_count = A1_primary_layout_spawner_count
		A_primary_layout_shot_range = A1_PRIMARY_LAYOUT_SHOT_RANGE
	elif A_attack_set == A_ATTACK_SET.SET_2:
		A_primary_layout_spawner_count = A2_primary_layout_spawner_count
		A_primary_layout_shot_range = A2_PRIMARY_LAYOUT_SHOT_RANGE
	elif A_attack_set == A_ATTACK_SET.SET_3:
		A_primary_layout_spawner_count = A3_primary_layout_spawner_count
		A_primary_layout_shot_range = A3_PRIMARY_LAYOUT_SHOT_RANGE
	
	A_Shooter = HELPER_01.instantiate()
	A_Shooter.create_self(
		A_primary_layout_spawner_count, 
		A_primary_layout_shot_range
	)
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_RED
			])
		])
	]
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_MAGENTA
			])
		])
	]
	A3_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_CYAN
			])
		])
	]
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_LAYOUT_SPAWNER_COUNT,
		B_layout_column_count, B_LAYOUT_COLUMN_RANGE
	)
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_WHITE
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
	
	if A_attack_set == A_ATTACK_SET.SET_1:
		A_Shooter.rotation_speed = 0
		A_Shooter.global_rotation = GlobalPlayer.angle_to_player(A_Shooter.global_position)
		
		A_Shooter.fire(
			A_travel_distance_curve, A_TRAVEL_DISTANCE_TIME,
			A_TRAVEL_DISTANCE_MINIMUM, A_TRAVEL_DISTANCE_MAXIMUM,
			A1_primary_fire_count,
			A1_PRIMARY_FIRE_DURATION,
			GlobalShooter.BRIGHT_RED,
			A1_secondary_layout_spawner_count,
			A1_SECONDARY_LAYOUT_SHOT_RANGE,
			A1_Bullets,
			A1_SECONDARY_BULLET_SPEED,
			A1_secondary_stack_count, 
			A1_SECONDARY_BULLET_STACK_SPEED,
			false
		)
		await A_Shooter.finished_round
	
	elif A_attack_set == A_ATTACK_SET.SET_2:
		A_Shooter.rotation_speed = A2_SHOOTER_ROTATION_SPEED * (-B_direction)
		
		A_Shooter.fire(
			A_travel_distance_curve, A_TRAVEL_DISTANCE_TIME,
			A_TRAVEL_DISTANCE_MINIMUM, A_TRAVEL_DISTANCE_MAXIMUM + 100,
			A2_primary_fire_count,
			A2_PRIMARY_FIRE_DURATION,
			GlobalShooter.BRIGHT_MAGENTA,
			A2_secondary_layout_spawner_count,
			A2_SECONDARY_LAYOUT_SHOT_RANGE,
			A2_Bullets,
			A2_SECONDARY_BULLET_SPEED,
			A2_secondary_stack_count, 
			A2_SECONDARY_BULLET_STACK_SPEED,
			false
		)
		await A_Shooter.finished_round
	
	elif A_attack_set == A_ATTACK_SET.SET_3:
		A_Shooter.rotation_speed = 0
		A_Shooter.global_rotation = GlobalPlayer.angle_to_player(A_Shooter.global_position)
		
		A_Shooter.fire(
			A_travel_distance_curve, A_TRAVEL_DISTANCE_TIME,
			A_TRAVEL_DISTANCE_MINIMUM, A_TRAVEL_DISTANCE_MAXIMUM,
			A3_primary_fire_count,
			A3_PRIMARY_FIRE_DURATION,
			GlobalShooter.BRIGHT_MAGENTA,
			A3_secondary_layout_spawner_count,
			A3_SECONDARY_LAYOUT_SHOT_RANGE,
			A2_Bullets,
			A3_SECONDARY_BULLET_SPEED,
			A3_secondary_stack_count, 
			A3_SECONDARY_BULLET_STACK_SPEED,
			false
		)
		await A_Shooter.finished_round
		await Boss.create_waiter(0.6).finished
		
		A_Shooter.fire(
			A_travel_distance_curve, A_TRAVEL_DISTANCE_TIME,
			A_TRAVEL_DISTANCE_MINIMUM, A_TRAVEL_DISTANCE_MAXIMUM,
			A3_primary_fire_count - 1,
			A3_PRIMARY_FIRE_DURATION,
			GlobalShooter.BRIGHT_CYAN,
			1,
			A3_SECONDARY_LAYOUT_SHOT_RANGE,
			A3_Bullets,
			A3_SECONDARY_BULLET_SPEED + 20,
			1, 
			A3_SECONDARY_BULLET_STACK_SPEED,
			true
		)
		await A_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	next_phase()


func attack_b() -> void:
	B_Shooter.rotation_speed = deg_to_rad(B_SHOOTER_ROTATION_SPEED) * B_direction
	B_Shooter.fire_round(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED
	)
	await B_Shooter.finished_round
	
	B_direction *= -1
	next_phase()


func move() -> void:
	await Boss.create_waiter(B_MOVE_WAIT).finished
	
	var rand_pos = GlobalStage.random_position(
		BOUND_RIGHT, BOUND_LEFT, BOUND_TOP, BOUND_BOTTOM, 
		Boss.position, DISTANCE, RNG
	)
	
	await Boss.move_boss(rand_pos, TIME).finished
	await Boss.create_waiter(AFTER_MOVE_WAIT).finished




func _on_Boss_tree_exiting():
	stopped = true
