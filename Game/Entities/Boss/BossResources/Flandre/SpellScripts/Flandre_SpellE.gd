extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.FLANDRE
const SPELL_ID := 5

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/SpellPortrait_Flandre.tres")
const BULLET_FLANDRE    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")
const HELPER_09         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper09.tscn")
const HELPER_10         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper10.tscn")
const HELPER_12         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper12.tscn")

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D

@export_group("Attack_B")
var B_phase:int = 0
######
var B1_Shooter:Shooter_Tween
var B1_Bullets:Array[RowData_Bullet]
@export_subgroup("B1")
@export var B1_layout_spawner_count:int
@export var B1_fire_count:int
const B1_FIRE_DURATION          :=    4.0
const B1_TWEEN_TIME             :=    6.0
const B1_TWEEN_MAX_ROTATION     :=   20.0
const B1_TWEEN_MIN_ROTATION     :=    0.0
######
var B2_Shooter:Shooter_Basic
var B2_Bullets:Array[RowData_Column]
@export_subgroup("B2")
@export var B2_layout_spawner_count:int
@export var B2_fire_count:int
@export var B2_round_count:int
const B2_ROUND_DURATION         :=    3.8
const B2_BULLET_SPEED           :=  260.0
const B2_BULLET_SPEED_RANGE     :=  180.0
#######
var B3_Shooter:Shooter_Basic
var B3_Bullets:Array[RowData_Column]
@export_subgroup("B3")
@export var B3_layout_spawner_count:int
@export var B3_layout_column_count:int
@export var B3_fire_count:int
const B3_LAYOUT_COLUMN_RANGE    :=   30.0
const B3_FIRE_DURATION          :=    4.0
const B3_BULLET_SPEED           :=  260.0
const B3_BULLET_SPEED_RANGE     :=   40.0
const B3_SHOOTER_ROTATION_SPEED :=  240.0

var C_Shooter:Node2D
var C_phase:int = 0
@export_group("Attack_C")
const C_FIRE_DURATION           :=    5.0
######
@export_subgroup("C1")
@export var C1_fire_count:int
@export_subgroup("C2")
@export var C2_fire_count:int

var D_Shooter:Node2D
var D_phase:int = 0
@export_group("Attack_D")
######
@export_subgroup("D1")
@export var D1_fire_count:int
const D1_FIRE_DURATION           :=    5.0
######
@export_subgroup("D2")
@export var D2_fire_count:int
const D2_FIRE_DURATION           :=    2.8

const MOVE_BOUND_RIGHT  := 620.0
const MOVE_BOUND_LEFT   :=  30.0
const MOVE_BOUND_TOP    :=  80.0
const MOVE_BOUND_BOTTOM := 300.0
const MOVE_DISTANCE     := 250.0
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
	
	A_Shooter = HELPER_09.instantiate()
	A_Shooter.position.y = 300
	Boss.add_child(A_Shooter)
	
	B1_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(B1_layout_spawner_count, ShapeTemplate.SHAPE.CIRCLE)
	)
	B1_Shooter.RNG = RNG
	B1_Shooter.rotation_random = true
	B1_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.MEDIUM_RED
		])
	]
	Boss.add_child(B1_Shooter)
	
	B2_Shooter = GlobalShooter.create_basic_shooter(B2_layout_spawner_count)
	B2_Shooter.RNG = RNG
	B2_Shooter.rotation_random = true
	B2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	Boss.add_child(B2_Shooter)
	
	B3_Shooter = GlobalShooter.create_basic_shooter(
		B3_layout_spawner_count,
		B3_layout_column_count, B3_LAYOUT_COLUMN_RANGE
	)
	B3_Shooter.RNG = RNG
	B3_Shooter.rotation_random = true
	B3_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	Boss.add_child(B3_Shooter)
	
	C_Shooter = HELPER_10.instantiate()
	C_Shooter.RNG = RNG
	Boss.add_child(C_Shooter)
	
	D_Shooter = HELPER_12.instantiate()
	D_Shooter.RNG = RNG
	Boss.add_child(D_Shooter)
	
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
	
	attack_a()
	await Boss.create_waiter(1.2).finished
	
	GlobalStage.change_player_default_position(A_Shooter.global_position)
	
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
	A_Shooter.disable()
	B1_Shooter.disable()
	B2_Shooter.disable()
	B3_Shooter.disable()
	C_Shooter.disable()
	D_Shooter.disable()
	
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
	
	GlobalStage.reset_player_default_position()
	
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
		attack_b()
	if phase == 1:
		attack_c()
	if phase == 2:
		attack_b()
	if phase == 3:
		attack_d()
	if phase == 4:
		attack_b()
	if phase == 5:
		attack_c()
	if phase == 6:
		attack_b()
	if phase == 7:
		attack_d()
	phase += 1


func attack_a():
	A_Shooter.start()


func attack_b():
	Boss.custom_animation("AttackA")
	
	if B_phase == 0:
		B1_Shooter.fire_round_full(
			B1_Bullets, 
			B1_fire_count, B1_FIRE_DURATION,
			0, 0,
			B1_TWEEN_TIME, B1_TWEEN_MAX_ROTATION, B1_TWEEN_MIN_ROTATION,
			false, [],
			1
		)
	if B_phase == 1:
		B1_Shooter.fire_round_full(
			B1_Bullets, 
			B1_fire_count, B1_FIRE_DURATION,
			0, 0,
			B1_TWEEN_TIME, B1_TWEEN_MAX_ROTATION, B1_TWEEN_MIN_ROTATION,
			true, [],
			1
		)
	if B_phase == 2:
		B1_Shooter.fire_round_full(
			B1_Bullets, 
			B1_fire_count, B1_FIRE_DURATION,
			0, 0,
			B1_TWEEN_TIME, B1_TWEEN_MAX_ROTATION, B1_TWEEN_MIN_ROTATION,
			false, [],
			1
		)
		for _i in B2_round_count:
			B2_Shooter.fire_round(
				B2_Bullets,
				B2_fire_count, 0,
				B2_BULLET_SPEED, B2_BULLET_SPEED_RANGE
			)
			await Boss.create_waiter(B2_ROUND_DURATION / B2_round_count).finished
	if B_phase == 3:
		B1_Shooter.fire_round_full(
			B1_Bullets, 
			B1_fire_count, B1_FIRE_DURATION,
			0, 0,
			B1_TWEEN_TIME, B1_TWEEN_MAX_ROTATION, B1_TWEEN_MIN_ROTATION,
			false, [],
			1
		)
		B3_Shooter.rotation_speed = deg_to_rad(B3_SHOOTER_ROTATION_SPEED)
		B3_Shooter.fire_round(
			B3_Bullets,
			B3_fire_count, B3_FIRE_DURATION,
			B3_BULLET_SPEED, B3_BULLET_SPEED_RANGE
		)
	await B1_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(0.8).finished
	
	B_phase += 1
	next_phase()


func attack_c():
	Boss.custom_animation("AttackB")
	
	if C_phase == 0:
		C_Shooter.fire_round_01(
			C1_fire_count, C_FIRE_DURATION
		)
	if C_phase == 1:
		C_Shooter.fire_round_02(
			C2_fire_count, C_FIRE_DURATION
		)
	await C_Shooter.round_finished
	
	Boss.return_animation()
	await Boss.create_waiter(0.8).finished
	
	C_phase += 1
	next_phase()


func attack_d():
	Boss.custom_animation("AttackB")
	
	if D_phase == 0:
		D_Shooter.fire_round_01(
			D1_fire_count, D1_FIRE_DURATION
		)
	if D_phase == 1:
		D_Shooter.fire_round_02(
			D2_fire_count, D2_FIRE_DURATION
		)
	await D_Shooter.round_finished
	
	Boss.return_animation()
	await Boss.create_waiter(2.4).finished
	
	D_phase += 1
	next_phase()


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
