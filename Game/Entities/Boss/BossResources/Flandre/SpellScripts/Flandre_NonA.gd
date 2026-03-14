extends BossEvent_Non

const BOSS_ID := GlobalSettings.BOSS.FLANDRE

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Patchouli/Sprite/SpellPortrait_Patchouli.tres")
const FLANDRE_BULLET    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
@export_group("Attack_A")
@export var A_layout_spawner_count:int
@export var A_spawn_stack_count:int
const A_FIRE_COUNT             :=   1
const A_FIRE_DURATION          :=   0.0
const A_BULLET_SPEED           := 180.0
const A_SPAWN_STACK_SPEED      :=  30.0

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
@export_group("Attack_B")
@export var B_layout_spawner_count:int
@export var B_spawn_stack_count:int
const B_FIRE_COUNT             :=   1
const B_FIRE_DURATION          :=   0.0
const B_BULLET_SPEED           := 160.0
const B_SPAWN_STACK_SPEED      :=  40.0

var C_Shooter:Shooter_Basic
var C_Bullets:Array[RowData_Column]
@export_group("Attack_C")
@export var C_layout_spawner_count:int
@export var C_fire_count:int
const C_FIRE_DURATION          :=   1.0
const C_BULLET_SPEED           := 180.0
const C_SHOOTER_ROTATION_SPEED := -60.0

var D_Shooter:Shooter_Basic
var D_Bullets:Array[RowData_Column]
@export_group("Attack_D")
@export var D_layout_spawner_count:int
@export var D_fire_count:int
const D_FIRE_DURATION          :=   1.0
const D_BULLET_SPEED           := 180.0
const D_SHOOTER_ROTATION_SPEED :=  40.0

var E_Shooter:Shooter_Basic
var E_Bullets:Array[RowData_Column]
@export_group("Attack_E")
@export var E_layout_spawner_count:int
const E_FIRE_COUNT             :=   1
const E_FIRE_DURATION          :=   0.0
const E_BULLET_SPEED           := 180.0
const E_SHOOTER_DISTANCE       := 100.0
const E_SHOOTER_DELAY          :=   0.1

const MOVE_BOUND_RIGHT  := 620
const MOVE_BOUND_LEFT   := 30
const MOVE_BOUND_TOP    := 80
const MOVE_BOUND_BOTTOM := 300
const MOVE_DISTANCE     := 250
const MOVE_TIME         :=   0.6

const WAIT_PREPARE      :=   0.8
const WAIT_START        :=   0.2
const WAIT_START_ADD    :=   0.8
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
	
	A_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A_Shooter.RNG = RNG
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(B_layout_spawner_count)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				FLANDRE_BULLET
			])
		])
	]
	Boss.add_child(B_Shooter)
	
	C_Shooter = GlobalShooter.create_basic_shooter(C_layout_spawner_count)
	C_Shooter.RNG = RNG
	C_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	Boss.add_child(C_Shooter)
	
	D_Shooter = GlobalShooter.create_basic_shooter(D_layout_spawner_count)
	D_Shooter.RNG = RNG
	D_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.LARGE_RED
			])
		])
	]
	Boss.add_child(D_Shooter)
	
	E_Shooter = GlobalShooter.create_basic_shooter(E_layout_spawner_count)
	E_Shooter.RNG = RNG
	E_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	Boss.add_child(E_Shooter)
	
	if special_animation:
		Boss.charge_on(EFFECT_CHARGE)
		EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return WAIT_PREPARE


func start() -> void:
	if special_animation:
		Boss.special_function("Idle_Transition")
		await Boss.animation_finished
		
		Boss.charge_off()
		Boss.spell_effect(EFFECT_SPELL)
		EventHandler.play_sound_boss(SOUND_SPELL)
		
		await Boss.create_waiter(WAIT_START_ADD).finished
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(WAIT_START).finished
	
	if special_animation:
		Boss.return_animation()
		await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
	stopped = false
	non_started.emit()
	Boss.enable()
	
	next_phase()
	attack_c_loop()
	attack_d_loop()
	attack_e_loop()


func stop() -> void:
	stopped = true
	Boss.reset_waiters()
	A_Shooter.disable()
	B_Shooter.disable()
	C_Shooter.disable()
	D_Shooter.disable()
	E_Shooter.disable()
	
	Boss.reset_animation()
	Death.start(Boss.position)
	EventHandler.play_sound_boss(SOUND_PHASE_MINOR)
	GlobalStage.boss_end_phase.emit()
	
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




func next_phase() -> void:
	if stopped:
		return
	
	if phase == 0:
		attack_a()
		attack_b()
		phase = 0


func attack_a() -> void:
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.fire_round_stack(
		A_Bullets,
		A_FIRE_COUNT, A_FIRE_DURATION,
		A_BULLET_SPEED, 0,
		0, 0,
		A_spawn_stack_count, A_SPAWN_STACK_SPEED
	)
	
	await Boss.get_tree().process_frame
	
	move()


func attack_b() -> void:
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	B_Shooter.fire_round_stack(
		B_Bullets,
		B_FIRE_COUNT, B_FIRE_DURATION,
		B_BULLET_SPEED, 0,
		0, 0,
		B_spawn_stack_count, B_SPAWN_STACK_SPEED
	)


func attack_c_loop() -> void:
	C_Shooter.rotation_speed = C_SHOOTER_ROTATION_SPEED
	C_Shooter.fire_round(
		C_Bullets,
		C_fire_count, C_FIRE_DURATION,
		C_BULLET_SPEED
	)
	await C_Shooter.finished_round
	
	attack_c_loop()


func attack_d_loop() -> void:
	D_Shooter.rotation_speed = D_SHOOTER_ROTATION_SPEED
	D_Shooter.fire_round(
		D_Bullets,
		D_fire_count, D_FIRE_DURATION,
		D_BULLET_SPEED
	)
	await D_Shooter.finished_round
	
	attack_d_loop()


func attack_e_loop() -> void:
	E_Shooter.position = Vector2.RIGHT.rotated(RNG.randf_range(0, TAU)) * E_SHOOTER_DISTANCE
	E_Shooter.rotation = RNG.randf_range(0, TAU)
	E_Shooter.fire_round(
		E_Bullets,
		E_FIRE_COUNT, E_FIRE_DURATION,
		E_BULLET_SPEED
	)
	await Boss.create_waiter(E_SHOOTER_DELAY).finished
	
	attack_e_loop()


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
