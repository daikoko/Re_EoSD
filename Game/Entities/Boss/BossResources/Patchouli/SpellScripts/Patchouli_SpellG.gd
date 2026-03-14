extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.PATCHOULI
const SPELL_ID := 7

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT_BASE := preload("res://Game/Entities/Boss/BossResources/Patchouli/Sprite/SpellPortrait_Patchouli.tscn")
const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Patchouli/Sprite/SpellPortraitData_PatchouliRed.tres")
const HELPER_19         := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper19.tscn")

var A_Shooter:Node2D
@export_group("Attack_A")
@export var A_layout_spawner_count:int
@export var A_layout_column_count:int
@export var A_fire_time:float
const A_LAYOUT_COUMN_RANGE  :=  16.0
const A_LAYOUT_SHOT_RANGE   := 160.0
const A_BULLET_SPEED        := 400.0
const A_BULLET_SPEED_RANGE  :=  80.0
const A_TURN_DELAY          :=   0.3
const A_TURN_DELAY_RANGE    :=   0.0
const A_TURN_TIME           :=   0.6
const A_TURN_TIME_RANGE     :=   0.2
const A_TURN_MAX            :=   0.0
const A_TURN_MAX_RANGE      :=   0.8

var B_Shooter:Shooter_Linear
var B_Bullets:Array[RowData_Column]
@export_group("Attack_B")
@export var B_fire_count:int
const B_FIRE_DURATION       :=    1.0
const B_BULLET_SPEED        :=  340.0
const B_BULLET_SPEED_RANGE  :=   40.0
const B_LINEAR_DELAY        :=    0.2
const B_LINEAR_TIME         :=    0.4
const B_LINEAR_SPEED_CHANGE := -180.0
const B_SPAWN_STACK_COUNT   :=    4
const B_SPAWN_STACK_SPEED   :=   20.0

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
	
	A_Shooter = HELPER_19.instantiate()
	A_Shooter.RNG = RNG
	A_Shooter.position.y = - 280
	A_Shooter.build(
		A_layout_spawner_count,
		A_layout_column_count,
		A_LAYOUT_COUMN_RANGE,
		A_LAYOUT_SHOT_RANGE
	)
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_linear_shooter(
		1, 1, 360, 360,
		240
	)
	B_Shooter.RNG = RNG
	B_Shooter.position.y = - 280
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_YELLOW
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
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT, SPELL_PORTRAIT_BASE)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(WAIT_START).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	attack_a()


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




func attack_a() -> void:
	A_Shooter.start(
		A_fire_time,
		A_BULLET_SPEED, A_BULLET_SPEED_RANGE,
		A_TURN_DELAY,   A_TURN_DELAY_RANGE,
		A_TURN_TIME,    A_TURN_TIME_RANGE,
		A_TURN_MAX,     A_TURN_MAX_RANGE
	)
	await A_Shooter.finished_start
	
	attack_b_loop()


func attack_b_loop():
	B_Shooter.rotation_random = true
	B_Shooter.rotation_random_range = Vector2(
		deg_to_rad(20),
		deg_to_rad(160)
	)
	B_Shooter.fire_round(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE,
		0, 0,
		B_LINEAR_DELAY,
		B_LINEAR_TIME,
		B_LINEAR_SPEED_CHANGE,
		0, 
		0, 0,
		B_SPAWN_STACK_COUNT, B_SPAWN_STACK_SPEED
	)
	await B_Shooter.finished_round
	
	attack_b_loop()


func move() -> void:
	var rand_pos = GlobalStage.random_position(
		MOVE_BOUND_RIGHT, MOVE_BOUND_LEFT, MOVE_BOUND_TOP, MOVE_BOUND_BOTTOM, 
		Boss.position, MOVE_DISTANCE, RNG
	)
	
	await Boss.move_boss(rand_pos, MOVE_TIME).finished
	await Boss.create_waiter(WAIT_AFTER_MOVE).finished







func _on_Boss_tree_exiting():
	stopped = true
