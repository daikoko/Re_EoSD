extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.FLANDRE
const SPELL_ID := 7

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/SpellPortrait_Flandre.tres")
const BULLET_FLANDRE    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")
const HELPER_15         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper15.tscn")

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D
@export_group("Attack_A")
@export_subgroup("A1")
@export var A1_count_min:int
@export var A1_count_max:int
@export_subgroup("A2")
@export var A2_count_min:int
@export var A2_count_max:int
var A_phase:int = 0

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column] = []
@export_group("Attack_B")
@export var B_layout_spawner_count:int
@export var B_layout_column_count:int
@export var B_fire_count:int
const B_LAYOUT_COLUMN_RANGE :=   30.0
const B_FIRE_DURATION       :=    2.0
const B_BULLET_SPEED        :=  160.0

const MOVE_BOUND_RIGHT  := 620.0
const MOVE_BOUND_LEFT   :=  30.0
const MOVE_BOUND_TOP    :=  80.0
const MOVE_BOUND_BOTTOM := 300.0
const MOVE_DISTANCE     := 250.0
const MOVE_TIME         :=   1.2

const WAIT_PREPARE      :=   1.2
const WAIT_START        :=   1.2
const WAIT_AFTER_ATTACK :=   0.4
const WAIT_AFTER_MOVE   :=   0.4
const WAIT_AFTER_EVENT  :=   0.8

const RAND_SEED         := 849522

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
	
	A_Shooter = HELPER_15.instantiate()
	A_Shooter.RNG = RNG
	GlobalStage.request_add_object.emit(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count,
		B_layout_column_count, B_LAYOUT_COLUMN_RANGE
	)
	B_Shooter.RNG = RNG
	B_Shooter.rotation_random = true
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
	
	await Boss.create_waiter(0.2).finished
	
	A_Shooter.start()
	await Boss.create_waiter(0.6).finished
	
	A_Shooter.start_tiles()
	next_phase()
	
	await Boss.create_waiter(1.6).finished
	attack_a_loop()


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
	
	if phase == 0:
		attack_b()
		phase = 0


func attack_a_loop():
	if A_phase == 0:
		A_Shooter.start_attack_small(A1_count_min, A1_count_max)
		A_phase += 1
	elif A_phase == 1:
		A_Shooter.start_attack_large(A2_count_min, A2_count_max)
		A_phase = 0
	
	await Boss.create_waiter(4.0).finished
	
	attack_a_loop()


func attack_b():
	Boss.custom_animation("AttackA")
	
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	B_Shooter.fire_round(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED
	)
	await B_Shooter.finished_round
	
	Boss.return_animation()
	await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
	move()


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
