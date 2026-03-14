extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.PATCHOULI
const SPELL_ID := 8

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT_BASE := preload("res://Game/Entities/Boss/BossResources/Patchouli/Sprite/SpellPortrait_Patchouli.tscn")
const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Patchouli/Sprite/SpellPortraitData_PatchouliWhite.tres")
const HELPER_21         := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper21.tscn")
const HELPER_22         := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper22.tscn")
const HELPER_23         := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper23.tscn")
const HELPER_24         := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper24.tscn")
const HELPER_25         := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper25.tscn")
const HELPER_26         := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper26.tscn")

var A_Shooter:Node2D
@export_group("Attack_A")
@export var A_layout_spawner_count:int
const A_LASER_DURATION         :=    1.6
const A_SHOOTER_ROTATION_SPEED :=   12.0
const A_SHOOTER_DELAY          :=    2.4

var B_Shooter:Node2D
@export_group("Shooter B")
@export var B_layout_spawner_count:int
@export var B_fire_count:int
const B_ARROW_SIZE             :=    2
const B_ARROW_LENGTH           :=  120.0
const B_ARROW_WIDTH            :=  120.0
const B_ARROW_DISPLACEMENT     :=  250.0
const B_FIRE_DURATION          :=    1.0
const B_BULLET_SPEED           :=  200.0
const B_SHOOTER_ROTATION_SPEED :=   90.0

var C_Shooter:Node2D
@export_group("Shooter C")
@export var C_layout_spawner_count:int
@export var C_fire_count:int
const C_FIRE_DURATION          :=    1.0
const C_BULLET_SPEED           :=  200.0
const C_SHOOTER_ROTATION_SPEED :=   90.0

var D_Shooter:Node2D
@export_group("Shooter D")
@export var D_layout_spawner_count:int
@export var D_fire_count:int
const D_FIRE_DURATION          :=    1.0
const D_BULLET_SPEED           :=  200.0
const D_SINE_AMPLITUDE         :=   40.0
const D_SINE_COMPRESSION       :=    4.0
const D_SHOOTER_DELAY          :=    1.0

var E_Shooter:Node2D
@export_group("Shooter E")
@export var E_layout_spawner_count:int
@export var E_fire_count:int
const E_FIRE_DURATION          :=    1.0
const E_BULLET_SPEED           :=  160.0
const E_SPAWN_STACK_COUNT      :=    4
const E_SPAWN_STACK_SPEED      :=   20.0
const E_SHOOTER_ROTATION_SPEED :=   90.0

var F_Shooter:Node2D

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
	
	A_Shooter = HELPER_21.instantiate()
	A_Shooter.RNG = RNG
	A_Shooter.build(A_layout_spawner_count)
	Boss.add_child(A_Shooter)
	
	B_Shooter = HELPER_22.instantiate()
	B_Shooter.RNG = RNG
	B_Shooter.build(
		B_layout_spawner_count,
		B_ARROW_SIZE, B_ARROW_LENGTH, B_ARROW_WIDTH,
		B_ARROW_DISPLACEMENT
	)
	Boss.add_child(B_Shooter)
	
	C_Shooter = HELPER_23.instantiate()
	C_Shooter.RNG = RNG
	C_Shooter.build(
		C_layout_spawner_count
	)
	Boss.add_child(C_Shooter)
	
	D_Shooter = HELPER_24.instantiate()
	D_Shooter.RNG = RNG
	D_Shooter.build(
		D_layout_spawner_count
	)
	Boss.add_child(D_Shooter)
	
	E_Shooter = HELPER_25.instantiate()
	E_Shooter.RNG = RNG
	E_Shooter.build(
		E_layout_spawner_count
	)
	Boss.add_child(E_Shooter)
	
	F_Shooter = HELPER_26.instantiate()
	F_Shooter.position.y = 20
	Boss.add_child(F_Shooter)
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return WAIT_PREPARE


func start() -> void:
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	Boss.custom_animation("AttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT, SPELL_PORTRAIT_BASE)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(WAIT_START).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	attack_f()


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
	C_Shooter.disable()
	D_Shooter.disable()
	E_Shooter.disable()
	F_Shooter.disable()
	
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




func next_phase_loop() -> void:
	if stopped:
		return
	
	var delays = [
		0.0,
		0.5,
		1.0,
		1.5,
	]
	
	var delays_shuffled = shuffle(delays)
	attack_b(delays_shuffled[0])
	attack_c(delays_shuffled[1])
	attack_d(delays_shuffled[2])
	attack_e(delays_shuffled[3])
	await Boss.create_waiter(2.0).finished
	
	next_phase_loop()


func attack_a():
	A_Shooter.fire(
		A_LASER_DURATION,
		A_SHOOTER_ROTATION_SPEED,
		A_SHOOTER_DELAY
	)


func attack_b(delay:float):
	await Boss.create_waiter(delay).finished
	
	B_Shooter.fire(
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED,
		B_SHOOTER_ROTATION_SPEED
	)


func attack_c(delay:float):
	await Boss.create_waiter(delay).finished
	
	C_Shooter.fire(
		C_fire_count, C_FIRE_DURATION,
		C_BULLET_SPEED,
		C_SHOOTER_ROTATION_SPEED
	)


func attack_d(delay:float):
	await Boss.create_waiter(delay).finished
	
	D_Shooter.fire(
		D_fire_count, D_FIRE_DURATION,
		D_BULLET_SPEED,
		D_SINE_AMPLITUDE, D_SINE_COMPRESSION
	)


func attack_e(delay:float):
	await Boss.create_waiter(delay).finished
	
	E_Shooter.fire(
		E_fire_count, E_FIRE_DURATION,
		E_BULLET_SPEED,
		E_SPAWN_STACK_COUNT, E_SPAWN_STACK_SPEED,
		E_SHOOTER_ROTATION_SPEED
	)


func attack_f():
	A_Shooter.start()
	B_Shooter.start()
	C_Shooter.start()
	D_Shooter.start()
	E_Shooter.start()
	F_Shooter.start()
	await F_Shooter.start_finished
	
	attack_a()
	next_phase_loop()


func move() -> void:
	var rand_pos = GlobalStage.random_position(
		MOVE_BOUND_RIGHT, MOVE_BOUND_LEFT, MOVE_BOUND_TOP, MOVE_BOUND_BOTTOM, 
		Boss.position, MOVE_DISTANCE, RNG
	)
	
	await Boss.move_boss(rand_pos, MOVE_TIME).finished
	await Boss.create_waiter(WAIT_AFTER_MOVE).finished


func shuffle(list:Array) -> Array:
	var list_new:Array = []
	var size = list.size()
	for _i in size:
		var rand_index = RNG.randi_range(0, list.size() - 1)
		list_new.append(list[rand_index])
		list.remove_at(rand_index)
	
	return list_new




func _on_Boss_tree_exiting():
	stopped = true
