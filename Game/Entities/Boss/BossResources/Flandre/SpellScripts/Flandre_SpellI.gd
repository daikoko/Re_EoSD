extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.FLANDRE
const SPELL_ID := 9

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/SpellPortrait_Flandre.tres")
const BULLET_FLANDRE    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")
const HELPER_25         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper25.tscn")
const HELPER_26         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper26.tscn")

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D
@export_group("Attack_A")
@export var A_speed:float

var B_Shooter:Node2D
@export_group("Attack_B")
@export var B_brick_fire_time:float
@export var B_fire_count:float
const B_BULLET_SPEED       :=  200.0
const B_BULLET_SPEED_RANGE :=   40.0

var C_Shooter:Shooter_Basic
var C_Bullets:Array[RowData_Column]
@export_group("Attack_C")
@export var C_layout_spawner_count:int
@export var C_fire_count:float
const C_LAYOUT_SHOT_RANGE  :=   60.0
const C_FIRE_DURATION      :=    1.2
const C_BULLET_SPEED       :=  200.0

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
	
	A_Shooter = HELPER_25.instantiate()
	GlobalStage.request_add_object.emit(A_Shooter)
	
	B_Shooter = HELPER_26.instantiate()
	B_Shooter.RNG = RNG
	B_Shooter.prepare(A_Shooter.get_ball())
	GlobalStage.request_add_object.emit(B_Shooter)
	
	C_Shooter = GlobalShooter.create_basic_shooter(
		C_layout_spawner_count,
		1, 360,
		C_LAYOUT_SHOT_RANGE
	)
	C_Shooter.RNG = RNG
	C_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	Boss.add_child(C_Shooter)
	
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
	
	await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
	attack_a_start()
	attack_b_start()
	await Boss.create_waiter(0.4).finished
	
	Boss.return_animation()
	await Boss.create_waiter(1.2).finished
	
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
		attack_c()
		phase = 0


func attack_a_start():
	A_Shooter.start(
		A_speed
	)


func attack_b_start():
	B_Shooter.start_loop(
		B_brick_fire_time,
		B_fire_count,
		B_BULLET_SPEED,
		B_BULLET_SPEED_RANGE
	)


func attack_c():
	Boss.custom_animation("AttackA")
	
	C_Shooter.rotation = GlobalPlayer.angle_to_player(Boss.position)
	C_Shooter.fire_round(
		C_Bullets,
		C_fire_count, C_FIRE_DURATION,
		C_BULLET_SPEED
	)
	await C_Shooter.finished_round
	
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
