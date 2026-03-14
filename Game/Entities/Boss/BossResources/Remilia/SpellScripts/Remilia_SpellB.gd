extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.REMILIA
const SPELL_ID := 2

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Remilia/Sprite/SpellPortrait_Remilia.tres")
const HELPER_01 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper01.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 446658

@export_group("Special")
@export var special_animation:bool = false

@export_group("Attack A")
var A1_Shooter:Shooter_Tween
var A2_Shooter:Shooter_Tween
var A_Bullets:Array[RowData_Bullet]
@export var A_layout_spawner_count:int
@export var A_fire_count:int
@export var A_tween_distance_curve:Curve
@export var A_tween_rotation_curve:Curve
const A_FIRE_DURATION := 2.0
const A_TWEEN_TIME := 1.8
const A_TWEEN_RELEASE_SPEED := 280
const A_TWEEN_RELEASE_ANGLE := 90

@export_group("Attack B")
var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
@export var B_layout_spawner_count:int
@export var B_layout_column_count:int
@export var B_fire_count:int
const B_LAYOUT_COLUMN_RANGE := 30.0
const B_FIRE_DURATION := 2.0
const B_BULLET_SPEED := 180.0

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.4
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
	
	A1_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(A_layout_spawner_count, ShapeTemplate.SHAPE.CIRCLE)
	)
	A1_Shooter.RNG = RNG
	A2_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(A_layout_spawner_count, ShapeTemplate.SHAPE.CIRCLE)
	)
	A2_Shooter.RNG = RNG
	A_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.KNIFE_RED
		])
	]
	Boss.add_child(A1_Shooter)
	Boss.add_child(A2_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count,
		B_layout_column_count, B_LAYOUT_COLUMN_RANGE
	)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	Boss.add_child(B_Shooter)
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return PREPARE_WAIT


func start() -> void:
	if special_animation:
		Boss.special_function("Idle_Transition")
		await Boss.animation_finished
	
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	Boss.custom_animation("AttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await GlobalStage.create_timer_short(Boss, START_WAIT).timeout
	
	Boss.return_animation()
	await GlobalStage.create_timer_short(Boss, AFTER_ATTACK_WAIT).timeout
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	next_phase()


func stop() -> void:
	if major_phase:
		Boss.charge_on(EFFECT_DEATH)
		EventHandler.slow()
		
		var SlowTimer = GlobalStage.create_timer(Boss, 1.0)
		SlowTimer.start()
		await SlowTimer.timeout
		
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
	
	if hide_background and SpellBackground != null:
		SpellBackground.fade_out()
	
	if hide_boss:
		Boss.disable()
	
	if move_boss:
		Boss.move_boss(GlobalStage.BOSS_DEFAULT_POSITION, AFTER_EVENT_WAIT)
	
	await Boss.create_waiter(AFTER_EVENT_WAIT).finished
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
		attack_b()
		phase = 0


func attack_a():
	Boss.custom_animation("AttackA")
	
	var rand_rot = RNG.randf_range(0, TAU)
	A1_Shooter.rotation = rand_rot
	A1_Shooter.bullet_direct = true
	A1_Shooter.immunity_time = 2.0
	A2_Shooter.rotation = rand_rot + (TAU / (A_layout_spawner_count * 2))
	A2_Shooter.shooter_reversed = true
	A2_Shooter.bullet_direct = true
	A2_Shooter.immunity_time = 2.0
	
	A1_Shooter.fire_round(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		0, 0,
		A_TWEEN_TIME, A_tween_distance_curve, A_tween_rotation_curve,
		A_TWEEN_RELEASE_SPEED,
		A_TWEEN_RELEASE_ANGLE
	)
	A2_Shooter.fire_round(
		A_Bullets, 
		A_fire_count, A_FIRE_DURATION,
		0, 0,
		A_TWEEN_TIME, A_tween_distance_curve, A_tween_rotation_curve,
		A_TWEEN_RELEASE_SPEED,
		A_TWEEN_RELEASE_ANGLE
	)
	await A1_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	move()


func attack_b():
	B_Shooter.rotation = GlobalPlayer.angle_to_player(B_Shooter.global_position)
	B_Shooter.fire_round(
		B_Bullets,
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
