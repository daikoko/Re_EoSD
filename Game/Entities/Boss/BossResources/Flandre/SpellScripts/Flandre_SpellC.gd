extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.FLANDRE
const SPELL_ID := 3

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/SpellPortrait_Flandre.tres")
const BULLET_FLANDRE    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")
const HELPER_05         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper05.tscn")

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D
@export_group("Attack_A")
@export var A_fire_count:int
const A_BULLET_SPEED       :=  360
const A_BULLET_SPEED_RANGE :=  160
const A_WAIT_AFTER_ATTACK  :=    2.0

var B_Shooter:Shooter_Tween
var B_Bullets:Array[RowData_Bullet]
@export_group("Attack B")
@export var B_layout_spawner_count:int
@export var B_fire_time:float
const B_TWEEN_TIME           :=   8.0
const B_TWEEN_MAX_ROTATION   :=   6.0
const B_TWEEN_MIN_ROTATION   :=   0.0
var b_direction:int = 1

const MOVE_BOUND_RIGHT  := 620.0
const MOVE_BOUND_LEFT   :=  30.0
const MOVE_BOUND_TOP    :=  80.0
const MOVE_BOUND_BOTTOM := 300.0
const MOVE_DISTANCE     := 250.0
const MOVE_TIME         :=   0.6
const MOVE_DELAY        :=   1.4

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
	RNG.randomize()
	
	A_Shooter = HELPER_05.instantiate()
	A_Shooter.RNG = RNG
	A_Shooter.position.y = 20
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(B_layout_spawner_count, ShapeTemplate.SHAPE.CIRCLE)
	)
	B_Shooter.RNG = RNG
	B_Shooter.rotation_random = true
	B_Shooter.position.y = 20
	B_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.MEDIUM_RED
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
	await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	A_Shooter.start()
	await Boss.create_waiter(0.3).finished
	
	next_phase()
	attack_a_loop()
	attack_b_loop()


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


func attack_a_loop():
	A_Shooter.fire(
		A_fire_count,
		A_BULLET_SPEED,
		A_BULLET_SPEED_RANGE
	)
	await A_Shooter.finished_round
	await Boss.create_waiter(A_WAIT_AFTER_ATTACK).finished
	
	attack_a_loop()


func attack_b_loop():
	B_Shooter.fire_round_full(
		B_Bullets,
		1, 0,
		0, 0,
		B_TWEEN_TIME, 
		B_TWEEN_MAX_ROTATION * b_direction, 
		B_TWEEN_MIN_ROTATION,
		false, [],
		1
	)
	await Boss.create_waiter(B_fire_time).finished
	
	b_direction *= -1
	attack_b_loop()


func move() -> void:
	var rand_pos = GlobalStage.random_position(
		MOVE_BOUND_RIGHT, MOVE_BOUND_LEFT, MOVE_BOUND_TOP, MOVE_BOUND_BOTTOM, 
		Boss.position, MOVE_DISTANCE, RNG
	)
	
	await Boss.move_boss(rand_pos, MOVE_TIME).finished
	await Boss.create_waiter(WAIT_AFTER_MOVE).finished
	await Boss.create_waiter(MOVE_DELAY).finished
	
	next_phase()




func _on_Boss_tree_exiting():
	stopped = true
