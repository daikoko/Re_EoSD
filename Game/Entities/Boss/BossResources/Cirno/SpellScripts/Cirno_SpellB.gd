extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.CIRNO
const SPELL_ID := 2

const EFFECT_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const CIRNO_HELPER_03 := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper03.tscn")
const SPELL_PORTRAIT := preload("res://Game/Entities/Boss/BossResources/Cirno/Sprite/SpellPortrait_Cirno.tres")

const RAND_SEED := 88857

var A_Shooter:Node2D
@export_group("Shooter_A")
@export var A_fire_count:int = 8
@export var A_spawn_stack_count:int = 4
const A_BULLET_TRAVEL_SPEED := 280
const A_BULLET_RELEASE_SPEED := 180

var B_Shooter:Shooter_Basic
var B_Bullets:Array[RowData_Column] = []
@export_group("Shooter_B")
@export var B_layout_spawner_count:int = 6
@export var B_fire_count:float = 1
const B_FIRE_DURATION := 1.0
const B_BULLET_SPEED := 200

const PREPARE_WAIT      := 1.2
const START_WAIT        := 1.2
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
	
	A_Shooter = CIRNO_HELPER_03.instantiate()
	A_Shooter.RNG = RNG
	Boss.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_basic_shooter(B_layout_spawner_count)
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
	
	return PREPARE_WAIT


func start() -> void:
	Boss.charge_off()
	Boss.spell_effect(EFFECT_SPELL)
	Boss.custom_animation("AttackB")
	EventHandler.play_sound_boss(SOUND_SPELL)
	EventHandler.boss_spell_activate(get_boss_spell(), SPELL_PORTRAIT)
	
	if show_background and SpellBackground != null:
		SpellBackground.fade_in()
	
	await Boss.create_waiter(START_WAIT).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	attack_a_loop()
	attack_b_loop()


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




func attack_a_loop() -> void:
	while (stopped == false):
		A_Shooter.fire(
			A_fire_count, A_spawn_stack_count,
			A_BULLET_TRAVEL_SPEED, A_BULLET_RELEASE_SPEED
		)
		await A_Shooter.finished_round
		
		A_Shooter.change_low()
		await Boss.create_waiter(0.1).finished


func attack_b_loop() -> void:
	while (stopped == false):
		B_Shooter.rotation = GlobalPlayer.angle_to_player(B_Shooter.global_position)
		B_Shooter.fire_round(
			B_Bullets, 
			B_fire_count, B_FIRE_DURATION, 
			B_BULLET_SPEED
		)
		await B_Shooter.finished_round




func _on_Boss_tree_exiting():
	stopped = true
