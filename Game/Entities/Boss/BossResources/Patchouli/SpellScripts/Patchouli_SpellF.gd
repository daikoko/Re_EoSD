extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.PATCHOULI
const SPELL_ID := 6

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT_BASE := preload("res://Game/Entities/Boss/BossResources/Patchouli/Sprite/SpellPortrait_Patchouli.tscn")
const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Patchouli/Sprite/SpellPortraitData_PatchouliBlue.tres")
const HELPER_17 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper17.tscn")

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
@export_group("Attack A")
@export var A_layout_spawner_count:int
@export var A_fire_count:int
const A_FIRE_DURATION            :=    0.6
const A_BULLET_SPEED             :=  280.0
const A_SHOOTER_ROUND_DELAY      :=    0.2

var B_Shooter:Node2D
@export_group("Attack B")
@export var B_layout_spawner_count:int
@export var B_fire_count:int
@export var B_round_count:int
const B_FIRE_DURATION            :=    0.6
const B_ROUND_DELAY              :=    0.2
const B_BULLET_SPEED             :=  240.0
const B_BULLET_TURNING           :=    0.6

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
	
	A_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A_Shooter.RNG = RNG
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.STONE_CYAN
			])
		])
	]
	Boss.add_child(A_Shooter)
	
	B_Shooter = HELPER_17.instantiate()
	B_Shooter.RNG = RNG
	B_Shooter.build(B_layout_spawner_count)
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
	
	Boss.return_animation()
	await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
	stopped = false
	spell_started.emit()
	Boss.enable()
	
	next_phase()
	attack_a_loop()


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




func next_phase() -> void:
	if stopped:
		return
	
	if phase == 0:
		attack_b()


func attack_a_loop() -> void:
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	A_Shooter.fire_round(
		A_Bullets,
		A_fire_count, A_FIRE_DURATION,
		A_BULLET_SPEED
	)
	await A_Shooter.finished_round
	await Boss.create_waiter(A_SHOOTER_ROUND_DELAY).finished
	
	attack_a_loop()


func attack_b() -> void:
	Boss.custom_animation("AttackA")
	
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	B_Shooter.fire(
		B_round_count, B_ROUND_DELAY,
		B_fire_count, B_FIRE_DURATION,
		B_BULLET_SPEED, B_BULLET_TURNING
	)
	await B_Shooter.finished_round
	
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
