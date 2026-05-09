extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.FLANDRE
const SPELL_ID := 6

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/SpellPortrait_Flandre.tres")
const BULLET_FLANDRE    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")
const HELPER_14         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper14.tscn")

@export_group("Special")
@export var special_animation:bool = false

var A_Shooter:Node2D
@export_group("Attack_A")
@export var A_shooter_count:int
@export var A_layout_spawner_count:int
@export var A_fire_count:int
const A_FIRE_DURATION        :=    1.2
const A_BULLET_SPEED         :=  240.0
const A_SHOOTER_HEALTH       :=  8000
const A_SHOOTER_ROTATION_MIN :=   20.0
const A_SHOOTER_ROTATION_MAX :=   30.0
var A_direction:int = 1

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column]
@export_group("Attack_B")
@export var B_layout_spawner_count:int
@export var B_fire_count:int
const B_LAYOUT_SHOT_RANGE    :=   30.0 
const B_FIRE_DURATION        :=    1.2
const B_BULLET_SPEED         :=  160.0
const B_BULLET_SPEED_RANGE   :=   60.0
var B_direction:int = 1

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

const RAND_SEED         := 846515

var Boss:BossObject
var SpellBackground:Background

var phase:int = 0
signal attack_a_called




func prepare(EventHandler:Control, BossDict:Dictionary) -> float:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	Boss = BossDict["boss"]
	Boss.tree_exiting.connect(_on_Boss_tree_exiting)
	SpellBackground = BossDict["background"]
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		B_layout_spawner_count,
		1, 360,
		B_LAYOUT_SHOT_RANGE
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
	
	attack_a_prepare()
	await Boss.create_waiter(0.2).finished
	
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


func attack_a_prepare():
	var previous_positions = []
	
	for _i in A_shooter_count:
		var rand_position = Vector2.ZERO
		
		var retry = true
		var tries:int = 120
		while retry and tries > 0:
			retry = false
			tries -= 1
			rand_position = Vector2(
				RNG.randf_range(60,  620),
				RNG.randf_range(100, 400)
			)
			
			for other_position in previous_positions:
				if rand_position.distance_squared_to(other_position) < 20000: 
					retry = true
		previous_positions.append(rand_position)
		
		var shooter = HELPER_14.instantiate()
		shooter.RNG = RNG
		shooter.position = rand_position
		shooter.build(
			Boss,
			A_SHOOTER_HEALTH,
			A_SHOOTER_ROTATION_MIN,
			A_SHOOTER_ROTATION_MAX,
			A_direction,
			A_layout_spawner_count,
			A_fire_count,
			A_FIRE_DURATION,
			A_BULLET_SPEED
		)
		
		attack_a_called.connect(shooter._on_Spell_attack_a_called)
		
		A_direction *= -1
		GlobalStage.request_add_object.emit(shooter)


func attack_a():
	attack_a_called.emit()


func attack_b():
	B_Shooter.rotation = (PI / 2) - (TAU * 0.35 * B_direction)
	B_Shooter.rotation_speed = (TAU * 0.70) / B_FIRE_DURATION * B_direction
	B_Shooter.fire_round(
		B_Bullets,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_SPEED_RANGE
	)
	await B_Shooter.finished_round
	await Boss.create_waiter(0.4).finished
	
	attack_a()
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
