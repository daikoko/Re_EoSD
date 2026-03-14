extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.MEILING
const SPELL_ID := 6

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Meiling/Sprite/SpellPortrait_MeilingExtra.tres")

@export_group("Attack A")
const A_FIRE_DURATION            :=    1.6
var A_direction                  :=    1     
################
var A1_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column]
@export_subgroup("Set 1")
@export var A1_layout_spawner_count:int
@export var A1_fire_count:int
const A1_LAYOUT_SHOT_RANGE       :=   60.0
const A1_BULLET_SPEED            :=  200.0
const A1_BULLET_SPEED_RANGE      :=   40.0
const A1_SHOOOTER_ROTATION_SPEED :=   60.0
################
var A2_Shooter:Shooter_Basic
var A2_Bullets:Array[RowData_Column]
@export_subgroup("Set 2")
@export var A2_layout_spawner_count:int
@export var A2_fire_count:int
const A2_LAYOUT_SHOT_RANGE       :=   30.0
const A2_BULLET_SPEED            :=  200.0
const A2_BULLET_SPEED_RANGE      :=   40.0
const A2_SHOOOTER_ROTATION_SPEED := -120.0

var B_Shooter:Shooter_Linear
var B_Bullets:Array[RowData_Column]
@export_group("Attack B")
@export var B_layout_spawner_count:int
@export var B_fire_count:int
const B_FIRE_DURATION            :=    0.6
const B_BULLET_SPEED             :=  320.0
const B_BULLET_SPEED_RANGE       :=   80.0
const B_LINEAR_DELAY             :=    0.4
const B_LINEAR_TIME              :=    0.8
const B_LINEAR_SPEED_CHANGE      := -120.0

const MOVE_BOUND_RIGHT  := 620
const MOVE_BOUND_LEFT   := 30
const MOVE_BOUND_TOP    := 80
const MOVE_BOUND_BOTTOM := 300
const MOVE_DISTANCE     := 250
const MOVE_TIME         :=   0.6

const WAIT_PREPARE      :=   1.2
const WAIT_START        :=   1.2
const WAIT_AFTER_ATTACK :=   0.4
const WAIT_AFTER_MOVE   :=   0.4
const WAIT_AFTER_EVENT  :=   0.8

const RAND_SEED         := 844661

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
	
	A1_Shooter = GlobalShooter.create_basic_shooter(
		A1_layout_spawner_count, 1, 360, 
		A1_LAYOUT_SHOT_RANGE,
		GlobalShooter.STANDARD_START,
		true,
		RNG
	)
	A1_Shooter.RNG = RNG
	for bullet in [
			GlobalShooter.SEED_GREEN,
			GlobalShooter.SEED_YELLOW,
			GlobalShooter.SEED_RED
		]:
		for _i in snappedi(A1_fire_count, 3) / 3:
			A1_Bullets.append(
				RowData_Column.new([
					ColumnData_Bullet.new([
						bullet
					])
				])
			)
	Boss.add_child(A1_Shooter)
	
	A2_Shooter = GlobalShooter.create_basic_shooter(
		A2_layout_spawner_count, 1, 360, 
		A2_LAYOUT_SHOT_RANGE,
		GlobalShooter.STANDARD_START,
		true,
		RNG
	)
	A2_Shooter.RNG = RNG
	for bullet in [
			GlobalShooter.SEED_CYAN,
			GlobalShooter.SEED_BLUE,
			GlobalShooter.SEED_MAGENTA
		]:
		for _i in snappedi(A2_fire_count, 3) / 3:
			A2_Bullets.append(
				RowData_Column.new([
					ColumnData_Bullet.new([
						bullet
					])
				])
			)
	Boss.add_child(A2_Shooter)
	
	B_Shooter = GlobalShooter.create_linear_shooter(
		B_layout_spawner_count, 1, 360,
		360,
		GlobalShooter.STANDARD_START,
		true,
		RNG)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_WHITE
			])
		])
	]
	Boss.add_child(B_Shooter)
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return WAIT_PREPARE


func start() -> void:
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	Boss.custom_animation("AttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(WAIT_START).finished
	
	Boss.return_animation()
	await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	next_phase()


func stop() -> void:
	if major_phase:
		Boss.charge_on(EFFECT_DEATH)
		EventHandler.slow()
		
		await Boss.create_waiter(1.0).finished
		
		Boss.charge_off()
		Boss.hide()
		EventHandler.slow_stop()
		EventHandler.shake(60, 2)
	
	stopped = true
	Boss.reset_waiters()
	A1_Shooter.disable()
	A2_Shooter.disable()
	B_Shooter.disable()
	
	Boss.reset_animation()
	Death.start(Boss.position)
	EventHandler.boss_spell_deactivate()
	EventHandler.calculate_bonus(base_points, bonus_points)
	GlobalStage.boss_end_phase.emit()
	
	if major_phase:
		EventHandler.play_sound_boss(SOUND_PHASE_MAJOR)
	else:
		EventHandler.play_sound_boss(SOUND_PHASE_MINOR)
	
	if hide_background:
		SpellBackground.fade_out()
	
	if hide_boss:
		Boss.disable()
	
	if move_boss:
		Boss.move_boss(GlobalStage.BOSS_DEFAULT_POSITION, WAIT_AFTER_EVENT)
	
	await Boss.create_waiter(WAIT_AFTER_EVENT).finished
	event_ended.emit()


func get_boss_id() -> int:
	return BOSS_ID


func get_spell_id() -> int:
	return SPELL_ID 




func next_phase() -> void:
	if stopped:
		return
	
	if phase == 0:
		attack_a()
		phase += 1
	elif phase == 1:
		attack_b()
		move()
		phase = 0


func attack_a() -> void:
	A1_Shooter.rotation =       RNG.randf_range(0, TAU)
	A1_Shooter.rotation_speed = deg_to_rad(A1_SHOOOTER_ROTATION_SPEED) * A_direction
	A1_Shooter.fire_round(
		A1_Bullets,
		snappedi(A1_fire_count, 3), A_FIRE_DURATION,
		A1_BULLET_SPEED, A1_BULLET_SPEED_RANGE
	)
	
	A2_Shooter.rotation =       RNG.randf_range(0, TAU)
	A2_Shooter.rotation_speed = deg_to_rad(A2_SHOOOTER_ROTATION_SPEED) * A_direction
	A2_Shooter.fire_round(
		A2_Bullets,
		snappedi(A2_fire_count, 3), A_FIRE_DURATION,
		A2_BULLET_SPEED, A2_BULLET_SPEED_RANGE
	)
	
	await A1_Shooter.finished_round
	
	A_direction *= -1
	next_phase()


func attack_b() -> void:
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	B_Shooter.rotation_random = true
	B_Shooter.fire_round(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE,
		0, 0,
		B_LINEAR_DELAY,
		B_LINEAR_TIME,
		B_LINEAR_SPEED_CHANGE
	)


func move() -> void:
	var rand_pos = GlobalStage.random_position(
		MOVE_BOUND_RIGHT, MOVE_BOUND_LEFT, MOVE_BOUND_TOP, MOVE_BOUND_BOTTOM, 
		Boss.position, MOVE_DISTANCE, RNG
	)
	
	await Boss.move_boss(rand_pos, MOVE_TIME).finished
	await Boss.create_waiter(WAIT_AFTER_MOVE).finished
	
	next_phase()







func _on_Boss_tree_exiting():
	stopped = true
