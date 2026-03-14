extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.REMILIA

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Remilia/Sprite/SpellPortrait_Remilia.tres")
const BULLET_REMILIA := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/Bullet_Remilia.tres")
const HELPER_15      := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper15.tscn")

const BOUND_RIGHT  := 640
const BOUND_LEFT   := 40
const BOUND_TOP    := 80
const BOUND_BOTTOM := 300
const DISTANCE     := 180
const TIME         := 0.6
const RAND_SEED    := 446658

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D
@export_group("A Shooter")
@export_subgroup("A1")
@export var A1_active:bool
@export var A1_fire_time:float = 1
@export_subgroup("A2")
@export var A2_active:bool
@export var A2_spawner_count:int = 1
@export_subgroup("A3")
@export var A3_active:bool
@export var A3_fire_time:float = 1

const PREPARE_WAIT      := 0.8
const START_WAIT        := 0.2
const START_WAIT_ADD    := 0.8
const AFTER_ATTACK_WAIT := 2.0
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
	
	A_Shooter = HELPER_15.instantiate()
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	
	if special_animation:
		Boss.charge_on(EFFECT_CHARGE)
		EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return PREPARE_WAIT


func start() -> void:
	if special_animation:
		Boss.special_function("Idle_Transition")
		await Boss.animation_finished
		
		Boss.charge_off()
		Boss.spell_effect(EFFECT_SPELL)
		EventHandler.play_sound_boss(SOUND_SPELL)
		
		await Boss.create_waiter(START_WAIT_ADD).finished
	
	if show_background:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(START_WAIT).finished
	
	stopped = false
	non_started.emit()
	Boss.enable()
	
	await Boss.create_waiter(AFTER_MOVE_WAIT).finished
	if A1_active: attack_a1_loop()
	if A3_active: attack_a3_loop()
	next_phase()


func stop() -> void:
	stopped = true
	Boss.reset_waiters()
	A_Shooter.disable()
	
	Boss.reset_animation()
	Death.start(Boss.position)
	EventHandler.play_sound_boss(SOUND_PHASE_MINOR)
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
	
	attack_a2()


func attack_a1_loop() -> void:
	while stopped == false:
		A_Shooter.fire_line()
		await Boss.create_waiter(A1_fire_time).finished


func attack_a2() -> void:
	if A2_active:
		Boss.custom_animation("AttackA")
		
		A_Shooter.fire_circle(A2_spawner_count)
		await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
		
		Boss.return_animation()
		await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	else:
		await Boss.create_waiter(AFTER_ATTACK_WAIT).finished
	
	move()


func attack_a3_loop() -> void:
	while stopped == false:
		A_Shooter.fire_cross()
		await Boss.create_waiter(A3_fire_time).finished


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
