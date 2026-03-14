extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.MEILING
const SPELL_ID := 2

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Meiling/Sprite/SpellPortrait_Meiling.tres")
const HELPER_02 := preload("res://Game/Entities/Boss/BossResources/Meiling/SpellResources/Helper02.tscn")

const RAND_SEED := 84585

var A_Shooter:Shooter_Basic
var A_Bullets:RowData
@export_group("Shooter A")
@export var A_fire_time:float = 0.2
const A_BULLET_SPEED := 200
const A_BULLET_SPEED_RANGE := 20
const A_SHOOTER_ROTATION_SPEED_MAX := 90.0
const A_SHOOTER_ROTATION_FLIP_TIME := 4.6
var A_FireTimer:Timer
var A_FlipTimer:Timer
var A_rot_speed:float = A_SHOOTER_ROTATION_SPEED_MAX
var A_direction:int = 1

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData]
@export_group("Shooter B")
@export var B_fire_time:float = 0.1
const B_BULLET_SPEED := 180
const B_BULLET_SPEED_RANGE := 50

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.2
const AFTER_ATTACK_WAIT := 0.4
const AFTER_MOVE_WAIT   := 0.4
const AFTER_EVENT_WAIT  := 0.8

var Boss:BossObject
var SpellBackground:Background
var MoveTween:Tween

var phase:int = 0




func prepare(EventHandler:Control, BossDict:Dictionary) -> float:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	Boss = BossDict["boss"]
	Boss.tree_exiting.connect(_on_Boss_tree_exiting)
	SpellBackground = BossDict["background"]
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	var A_shooter_helper = HELPER_02.instantiate()
	Boss.add_child(A_shooter_helper)
	A_Shooter = GlobalShooter.create_basic_shooter_map(
		A_shooter_helper.build_basic()
	)
	A_Shooter.RNG = RNG
	A_Bullets = A_shooter_helper.get_a_bullets()
	Boss.add_child(A_Shooter)
	A_FireTimer = GlobalStage.create_timer(
		A_Shooter, 
		A_fire_time, false
	)
	A_FlipTimer = GlobalStage.create_timer(
		A_Shooter, 
		A_SHOOTER_ROTATION_FLIP_TIME, false
	)
	A_FlipTimer.timeout.connect(_on_FlipTimer_timeout)
	
	B_Shooter = GlobalShooter.create_basic_shooter(1, 1, 360, 360, 40)
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.MEDIUM_YELLOW
			])
		])
	]
	Boss.add_child(B_Shooter)
	
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
	A_FireTimer.start()
	A_FlipTimer.start()
	while true:
		if stopped:
			return
		A_Shooter.rotation_speed = deg_to_rad(A_rot_speed)
		A_Shooter.fire_row(
			A_Bullets,
			A_BULLET_SPEED, A_BULLET_SPEED_RANGE
		)
		await A_FireTimer.timeout


func attack_b():
	while true:
		if stopped:
			return
		for i in 6:
			B_Shooter.rotation = RNG.randf_range(0, TAU)
			B_Shooter.fire_row(
				B_Bullets[0], 
				B_BULLET_SPEED, B_BULLET_SPEED_RANGE
			)
		await Boss.create_waiter(B_fire_time).finished




func _on_Boss_tree_exiting():
	stopped = true


func _on_FlipTimer_timeout():
	A_direction *= -1
	
	var FlipTween = GlobalStage.create_tween()
	FlipTween.tween_property(
		self, 
		"A_rot_speed", 
		A_direction * A_SHOOTER_ROTATION_SPEED_MAX, 
		3.0
	)
