extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.RUMIA
const SPELL_ID := 4

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const HELPER_01 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper01.tscn")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Rumia/Sprite/SpellPortrait_Rumia.tres")

const RAND_SEED := 19241

var A_Shooter:Shooter_Basic
var A_Bullets:RowData_Column
@export_group("Shooter A")
@export var A_layout_spawners:int = 1
const A_LAYOUT_COLUMN_COUNT := 4
const A_LAYOUT_COLUMN_RANGE := 40
const A_FIRE_TIME := 0.1
const A_BULLET_SPEED := 200
const A_SHOOTER_ROTATION_MAX_SPEED := 30.0
const A_SHOOTER_ROTATION_FLIP_TIME := 3.0
var A_direction:int = 1

var B_Shooter:Shooter_Basic
var B_Bullets:RowData_Column
@export_group("Shooter B")
@export var B_layout_spawners:int = 1
const B_LAYOUT_DISTANCE := 60.0
const B_FIRE_TIME:float = 0.1
const B_BULLET_SPEED:float = 180

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.4
const AFTER_ATTACK_WAIT := 0.4
const AFTER_MOVE_WAIT   := 0.4
const AFTER_EVENT_WAIT  := 0.8

var Boss:BossObject
var SpellBackground:Background
var Bubble:Node2D

var phase:int = 0




func prepare(EventHandler:Control, BossDict:Dictionary) -> float:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	Boss = BossDict["boss"]
	Boss.tree_exiting.connect(_on_Boss_tree_exiting)
	SpellBackground = BossDict["background"]
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawners, 
		A_LAYOUT_COLUMN_COUNT, A_LAYOUT_COLUMN_RANGE
	)
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	A_Bullets = RowData_Column.new([
		ColumnData_Bullet.new([
			GlobalShooter.SPADE_YELLOW
		])
	])
	
	B_Shooter = GlobalShooter.create_basic_shooter(
		A_layout_spawners, 
		1, 360, 
		360, 
		GlobalShooter.STANDARD_START,
		true, RNG
	)
	B_Shooter.RNG = RNG
	Boss.add_child(B_Shooter)
	B_Bullets = RowData_Column.new([
		ColumnData_Bullet.new([
			GlobalShooter.MEDIUM_RED
		])
	])
	
	Bubble = HELPER_01.instantiate()
	Bubble.scale = Vector2.ZERO
	Boss.add_child(Bubble)
	
	Boss.charge_on(EFFECT_CHARGE)
	EventHandler.play_sound_boss(SOUND_CHARGE)
	
	return PREPARE_WAIT


func start() -> void:
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	Boss.custom_animation("AttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await GlobalStage.create_timer_short(Boss, START_WAIT).timeout
	
	var BubbleTween = Boss.create_tween()
	BubbleTween.tween_property(Bubble, "scale", Vector2.ONE * 0.4, 1.0)
	BubbleTween.tween_property(Bubble, "scale", Vector2.ONE * 1.0, time)
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	attack_a()
	attack_b()


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
	A_Shooter.disable()
	B_Shooter.disable()
	Bubble.queue_free()
	
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
		Boss.move_boss(GlobalStage.BOSS_DEFAULT_POSITION, AFTER_EVENT_WAIT)
	
	await Boss.create_waiter(AFTER_EVENT_WAIT).finished
	event_ended.emit()


func get_boss_id() -> int:
	return BOSS_ID


func get_spell_id() -> int:
	return SPELL_ID 




func attack_a():
	A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_MAX_SPEED)
	flip_loop()
	
	while true:
		if stopped:
			return
		A_Shooter.fire_row(
			A_Bullets, 
			A_BULLET_SPEED
		)
		await Boss.create_waiter(A_FIRE_TIME).finished


func attack_b():
	while true:
		if stopped:
			return
		B_Shooter.rotation = RNG.randf_range(0, TAU)
		B_Shooter.fire_row(
			B_Bullets, 
			B_BULLET_SPEED
		)
		await Boss.create_waiter(B_FIRE_TIME).finished


func flip_loop():
	await Boss.create_waiter(A_SHOOTER_ROTATION_FLIP_TIME).finished
	
	flip_rotation()
	flip_loop()


func flip_rotation() -> void:
	A_direction *= -1
	
	var FlipTween = Boss.create_tween()
	FlipTween.tween_property(
		A_Shooter, 
		"rotation_speed", 
		deg_to_rad(A_SHOOTER_ROTATION_MAX_SPEED) * A_direction, 
		3.0
	)




func _on_Boss_tree_exiting():
	stopped = true
