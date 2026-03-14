extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.FLANDRE
const SPELL_ID := 8

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/SpellPortrait_Flandre.tres")
const BULLET_FLANDRE    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")
const HELPER_18         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper18.tscn")
const HELPER_19         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper19.tscn")
const HELPER_20         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper20.tscn")
const HELPER_21         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper21.tscn")
const HELPER_22         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper22.tscn")
const HELPER_23         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper23.tscn")
const HELPER_24         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper24.tscn")

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D

var B_Shooter:Node2D
@export_group("Attack_B")
const B_FIRE_DURATION       :=    6.0
@export_subgroup("B1")
@export var B1_layout_spawner_count:int
@export var B1_fire_count:int
const B1_BULLET_SPEED          :=  100.0
@export_subgroup("B2")
@export var B2_layout_spawner_count:int
@export var B2_fire_count:int
const B2_TWEEN_TIME            :=   12.0
const B2_TWEEN_ROTATION_MAX    :=   10.0
const B2_TWEEN_ROTATION_MIN    :=    0.0

var C_Shooter:Node2D
@export_group("Attack_C")
const C_FIRE_DURATION          :=    6.0
@export_subgroup("C1")
@export var C1_layout_spawner_count:int
@export var C1_fire_count:int
const C1_ARROW_SIZE             :=    5
const C1_ARROW_LENGTH           :=  120.0
const C1_ARROW_WIDTH            :=  120.0
const C1_ARROW_DISPLACEMENT     :=  250.0
const C1_BULLET_SPEED           :=  120.0
const C1_SHOOTER_ROTATION_SPEED :=   90.0
@export_subgroup("C2")
@export var C2_layout_spawner_count:int
@export var C2_fire_count:int
const C2_BULLET_SPEED           :=  120.0
const C2_BULLET_SPEED_RANGE     :=   40.0

var D_Shooter:Node2D
@export_group("Attack_D")
const D_FIRE_DURATION           :=    6.0
@export_subgroup("D1")
@export var D1_layout_spawner_count:int
@export var D1_fire_count:int
const D1_BULLET_SPEED           :=  100.0
const D1_SHOOTER_ROTATION_SPEED :=   30.0
@export_subgroup("D2")
@export var D2_layout_spawner_count:int
@export var D2_fire_count:int
@export var D2_round_count:int
const D2_BULLET_SPEED           :=  100.0
const D2_BULLET_SPEED_RANGE     :=   20.0

var E_Shooter:Node2D
@export_group("Attack_E")
const E_FIRE_DURATION           :=    6.0
@export_subgroup("E1")
@export var E1_layout_spawner_count:int
const E1_LASER_DELAY            :=    0.4
const E1_LASER_DURATION         :=    1.0
const E1_SHOOTER_ROTATION_SPEED :=    8.0
const E1_SHOOTER_FIRE_COUNT     :=    3
const E1_SHOOTER_DELAY          :=    1.6
@export_subgroup("E2")
@export var E2_layout_spawner_count:int
@export var E2_layout_column_count:int
@export var E2_fire_count:int
const E2_LAYOUT_COLUMN_RANGE   :=   30.0
const E2_BULLET_SPEED          :=  100.0
const E2_BULLET_SPEED_RANGE    :=   20.0
const E2_SHOOTER_ROTATION_SPEED :=  40.0

var F_Shooter:Node2D
@export_group("Attack_F")
const F_FIRE_DURATION           :=    6.0
@export_subgroup("F1")
@export var F1_layout_spawner_count:int
@export var F1_layout_column_count:int
@export var F1_fire_count:int
@export var F1_spawn_stack_count:int
const F1_LAYOUT_COLUMN_RANGE    :=   40.0
const F1_BULLET_SPEED           :=   80.0
const F1_SPAWN_STACK_SPEED      :=   15.0
@export_subgroup("F2")
@export var F2_layout_spawner_count:int
@export var F2_fire_count:int
const F2_BULLET_SPEED           :=  120.0
const F2_BULLET_SPEED_RANGE     :=   40.0

var G_Shooter:Node2D
@export_group("Attack_G")
const G_FIRE_DURATION           :=    6.0
@export_subgroup("G1")
@export var G1_layout_spawner_count:int
@export var G1_fire_count:int
const G1_BULLET_SPEED           :=  120.0
const G1_SHOOTER_ROTATION_SPEED :=  160.0
@export_subgroup("G2")
@export var G2_layout_spawner_count:int
@export var G2_fire_count:int
const G2_BULLET_SPEED           :=  120.0
const G2_BULLET_SPEED_RANGE     :=   40.0

const MOVE_BOUND_RIGHT  := 620.0
const MOVE_BOUND_LEFT   :=  30.0
const MOVE_BOUND_TOP    :=  80.0
const MOVE_BOUND_BOTTOM := 300.0
const MOVE_DISTANCE     := 250.0
const MOVE_TIME         :=   1.2

const MOVE_LIST := [
	Vector2(520, 160),
	Vector2(120, 360),
	Vector2(560, 360),
	Vector2(160, 160),
	Vector2(340, 260),
]
var move_phase:int = 0

const WAIT_PREPARE      :=   1.2
const WAIT_START        :=   1.8
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
	
	A_Shooter = HELPER_18.instantiate()
	Boss.add_child(A_Shooter)
	
	B_Shooter = HELPER_19.instantiate()
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	
	C_Shooter = HELPER_20.instantiate()
	C_Shooter.RNG = RNG
	Boss.add_child(C_Shooter)
	
	D_Shooter = HELPER_21.instantiate()
	D_Shooter.RNG = RNG
	Boss.add_child(D_Shooter)
	
	E_Shooter = HELPER_22.instantiate()
	E_Shooter.RNG = RNG
	Boss.add_child(E_Shooter)
	
	F_Shooter = HELPER_23.instantiate()
	F_Shooter.RNG = RNG
	Boss.add_child(F_Shooter)
	
	G_Shooter = HELPER_24.instantiate()
	G_Shooter.RNG = RNG
	Boss.add_child(G_Shooter)
	
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
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	attack_a_start()
	await Boss.create_waiter(1.0).finished
	
	Boss.return_animation()
	await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
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
	B_Shooter.disable()
	C_Shooter.disable()
	D_Shooter.disable()
	E_Shooter.disable()
	F_Shooter.disable()
	G_Shooter.disable()
	
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
		phase += 1
	elif phase == 1:
		attack_c()
		phase += 1
	elif phase == 2:
		attack_d()
		phase += 1
	elif phase == 3:
		attack_e()
		phase += 1
	elif phase == 4:
		attack_f()
		phase += 1
	elif phase == 5:
		attack_g()
		phase += 1


func attack_a_start():
	A_Shooter.start()


func attack_b():
	Boss.custom_animation("AttackA")
	
	B_Shooter.start(
		B1_layout_spawner_count,
		B1_fire_count,
		B_FIRE_DURATION,
		B1_BULLET_SPEED,
		B2_layout_spawner_count,
		B2_fire_count,
		B_FIRE_DURATION,
		B2_TWEEN_TIME,
		B2_TWEEN_ROTATION_MAX,
		B2_TWEEN_ROTATION_MIN
	)
	await B_Shooter.finished_round
	
	B_Shooter.disable()
	Boss.return_animation()
	await Boss.create_waiter(0.6).finished
	
	move()


func attack_c():
	Boss.custom_animation("AttackA")
	
	C_Shooter.start(
		C1_layout_spawner_count,
		C1_ARROW_SIZE,
		C1_ARROW_LENGTH,
		C1_ARROW_WIDTH,
		C1_ARROW_DISPLACEMENT,
		C1_fire_count,
		C_FIRE_DURATION,
		C1_BULLET_SPEED,
		C1_SHOOTER_ROTATION_SPEED,
		C2_layout_spawner_count,
		C2_fire_count,
		C_FIRE_DURATION,
		C2_BULLET_SPEED,
		C2_BULLET_SPEED_RANGE
		
	)
	await C_Shooter.finished_round
	
	C_Shooter.disable()
	Boss.return_animation()
	await Boss.create_waiter(0.6).finished
	
	move()



func attack_d():
	Boss.custom_animation("AttackA")
	
	D_Shooter.start(
		D1_layout_spawner_count,
		D1_fire_count,
		D_FIRE_DURATION,
		D1_BULLET_SPEED,
		D1_SHOOTER_ROTATION_SPEED,
		D2_layout_spawner_count,
		D2_fire_count,
		D2_round_count,
		D_FIRE_DURATION,
		D2_BULLET_SPEED,
		D2_BULLET_SPEED_RANGE,
	)
	await D_Shooter.finished_round
	
	D_Shooter.disable()
	Boss.return_animation()
	await Boss.create_waiter(0.6).finished
	
	move()



func attack_e():
	Boss.custom_animation("AttackA")
	
	E_Shooter.start(
		E1_layout_spawner_count,
		E1_LASER_DELAY,
		E1_LASER_DURATION,
		E1_SHOOTER_ROTATION_SPEED,
		E1_SHOOTER_FIRE_COUNT,
		E1_SHOOTER_DELAY,
		E2_layout_spawner_count,
		E2_layout_column_count,
		E2_LAYOUT_COLUMN_RANGE,
		E2_fire_count,
		E_FIRE_DURATION,
		E2_BULLET_SPEED,
		E2_BULLET_SPEED_RANGE,
		E2_SHOOTER_ROTATION_SPEED
	)
	await E_Shooter.finished_round
	
	E_Shooter.disable()
	Boss.return_animation()
	await Boss.create_waiter(0.6).finished
	
	move()



func attack_f():
	Boss.custom_animation("AttackA")
	
	F_Shooter.start(
		F1_layout_spawner_count,
		F1_layout_column_count,
		F1_LAYOUT_COLUMN_RANGE,
		F1_fire_count,
		F_FIRE_DURATION,
		F1_BULLET_SPEED,
		F1_spawn_stack_count,
		F1_SPAWN_STACK_SPEED,
		F2_layout_spawner_count,
		F2_fire_count,
		F_FIRE_DURATION,
		F2_BULLET_SPEED,
		F2_BULLET_SPEED_RANGE
	)
	await F_Shooter.finished_round
	
	F_Shooter.disable()
	Boss.return_animation()
	await Boss.create_waiter(0.6).finished
	
	move()



func attack_g():
	Boss.custom_animation("AttackA")
	
	G_Shooter.start(
		G1_layout_spawner_count,
		G1_fire_count,
		G_FIRE_DURATION,
		G1_BULLET_SPEED,
		G1_SHOOTER_ROTATION_SPEED,
		G2_layout_spawner_count,
		G2_fire_count,
		G_FIRE_DURATION,
		G2_BULLET_SPEED,
		G2_BULLET_SPEED_RANGE,
	)
	await G_Shooter.finished_round
	
	G_Shooter.disable()
	Boss.return_animation()



func move() -> void:
	var move_pos = MOVE_LIST[move_phase]
	
	await Boss.move_boss(move_pos, MOVE_TIME).finished
	await Boss.create_waiter(WAIT_AFTER_MOVE).finished
	
	move_phase += 1
	next_phase()




func _on_Boss_tree_exiting():
	stopped = true
