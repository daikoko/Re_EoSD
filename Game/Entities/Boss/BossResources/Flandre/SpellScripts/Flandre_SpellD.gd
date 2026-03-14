extends BossEvent_Spell

const BOSS_ID := GlobalSettings.BOSS.FLANDRE
const SPELL_ID := 4

const EFFECT_CHARGE     := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Charge.tres")
const EFFECT_SPELL      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_Spell.tres")
const EFFECT_DEATH      := preload("res://Game/Entities/Boss/BossResources/_General/Particles/Particles_ChargeDeath.tres")
const SOUND_CHARGE      := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell01.wav")
const SOUND_SPELL       := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Spell02.wav")
const SOUND_PHASE_MINOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase01.wav")
const SOUND_PHASE_MAJOR := preload("res://Game/Entities/Boss/BossResources/_General/Sound/Boss_Phase02.wav")

const SPELL_PORTRAIT    := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/SpellPortrait_Flandre.tres")
const BULLET_FLANDRE    := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Bullet_Flandre.tres")
const HELPER_07         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper07.tscn")
const HELPER_08         := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper08.tscn")

const BOSS              := preload("res://Game/Entities/Boss/BossScripts/Boss.tscn")
const SPRITE            := preload("res://Game/Entities/Boss/BossResources/Flandre/Sprite/BossSprite_Flandre.tres")
const MARKER_BLUE       := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/BulletCustom_FlandrePlayer01.png")
const MARKER_RED        := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/BulletCustom_FlandrePlayer02.png")
const MARKER_GREEN      := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/BulletCustom_FlandrePlayer03.png")
const MARKER_YELLOW     := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/BulletCustom_FlandrePlayer04.png")

enum TARGET {
	BLUE,
	RED,
	GREEN,
	YELLOW
}

@export_group("Special")
@export var special_animation:bool = false

@export_group("Attack_A")
@export var A_layout_spawner_count:int
@export var A_fire_count:int
const A_FIRE_DURATION :=    2.0
const A_BULLET_SPEED  :=  180.0
######
var A1_Shooter:Shooter_Basic
var A1_Bullets:Array[RowData_Column]
######
var A2_Shooter:Shooter_Basic
var A2_Bullets:Array[RowData_Column]
######
var A3_Shooter:Shooter_Basic
var A3_Bullets:Array[RowData_Column]
######
var A4_Shooter:Shooter_Basic
var A4_Bullets:Array[RowData_Column]

@export_group("Attack_B")
const B_FIRE_DURATION  := 2.0
######
var B1_Shooter:Shooter_Tween
var B1_Bullets:Array[RowData_Bullet]
@export_subgroup("B1")
@export var B1_layout_spawner_count:int
@export var B1_fire_count:int
const B1_TWEEN_TIME           :=   8.0
const B1_TWEEN_MAX_ROTATION   :=  12.0
const B1_TWEEN_MIN_ROTATION   :=   0.0
######
var B2_Shooter:Shooter_Laser
var B2_Bullets:RowData_Column
@export_subgroup("B2")
@export var B2_layout_spawner_count:int
const B2_LAYOUT_DISTANCE            :=   80.0
const B2_LASER_DELAY                :=    0.6
const B2_LASER_DURATION             :=    0.8
const B2_SHOOTER_ROTATION_SPEED_MAX :=  360.0
const B2_SHOOTER_ROTATION_SPEED_MIN :=   20.0
const B2_SHOOTER_ROTATION_TIME      :=    1.0
var B2_direction:int = 1
######
var B3_Shooter:Shooter_Arrow
var B3_Bullets:Array[RowData_Column]
@export_subgroup("B3")
@export var B3_layout_spawner_count:int
@export var B3_fire_count:int
const B3_ARROW_SIZE             :=    3
const B3_ARROW_LENGTH           :=  120.0
const B3_ARROW_WIDTH            :=  120.0
const B3_ARROW_DISPLACEMENT     :=  250.0
const B3_ARROW_FILLED           :=   true
const B3_BULLET_SPEED           :=  240.0
const B3_SHOOTER_ROTATION_SPEED :=   90.0
######
var B4_Shooter:Shooter_Basic
var B4_Bullets:Array[RowData_Column]
@export_subgroup("B4")
@export var B4_layout_spawner_count:int
@export var B4_layout_column_count:int
@export var B4_fire_count:int
const B4_LAYOUT_COLUMN_RANGE    :=   30.0
const B4_BULLET_SPEED           :=  260.0
const B4_SHOOTER_ROTATION_SPEED :=  180.0
var B4_direction:int = 1

const MOVE_BOUND_RIGHT  := 620.0
const MOVE_BOUND_LEFT   :=  30.0
const MOVE_BOUND_TOP    := 120.0
const MOVE_BOUND_BOTTOM := 320.0
const MOVE_DISTANCE     := 250.0
const MOVE_TIME         :=   0.6
const MOVE_DELAY        :=   1.4

const WAIT_PREPARE      :=   1.2
const WAIT_START        :=   1.2
const WAIT_AFTER_ATTACK :=   0.4
const WAIT_AFTER_MOVE   :=   0.4
const WAIT_AFTER_EVENT  :=   0.8

const RAND_SEED         := 774512

var Boss:BossObject
var SpellBackground:Background

var BossBlue:BossObject
var BossRed:BossObject
var BossGreen:BossObject
var BossYellow:BossObject

var BossBlueActive:bool
var BossRedActive:bool
var BossGreenActive:bool
var BossYellowActive:bool

var MarkerBlue:Node2D
var MarkerRed:Node2D
var MarkerGreen:Node2D
var MarkerYellow:Node2D

var ParticleWhite:Node2D
var ParticleBlue:Node2D
var ParticleRed:Node2D
var ParticleGreen:Node2D
var ParticleYellow:Node2D

var phase:int = 0




func prepare(EventHandler:Control, BossDict:Dictionary) -> float:
	self.EventHandler = EventHandler
	self.BossDict = BossDict
	Boss = BossDict["boss"]
	Boss.tree_exiting.connect(_on_Boss_tree_exiting)
	SpellBackground = BossDict["background"]
	
	RNG = RandomNumberGenerator.new()
	RNG.seed = RAND_SEED
	
	ParticleWhite = HELPER_07.instantiate()
	ParticleWhite.set_color(Color(1, 1, 1, 1))
	Boss.add_child(ParticleWhite)
	
	BossBlue = BOSS.instantiate()
	BossBlue.toggle_bomb_immunity()
	BossBlue.set_sprite(SPRITE)
	BossBlue.special_function("change_base_color", [Color(0, 1, 1, 1)])
	BossBlue.disable()
	ParticleBlue = HELPER_07.instantiate()
	ParticleBlue.set_color(Color(0, 1, 1, 1))
	BossBlue.add_child(ParticleBlue)
	MarkerBlue = HELPER_08.instantiate()
	MarkerBlue.set_sprite(MARKER_BLUE)
	BossBlue.add_child(MarkerBlue)
	GlobalStage.request_add_object.emit(BossBlue)
	
	A1_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A1_Shooter.RNG = RNG
	A1_Shooter.rotation_random = true
	A1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_CYAN
			])
		])
	]
	BossBlue.add_child(A1_Shooter)
	
	B1_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(B1_layout_spawner_count, ShapeTemplate.SHAPE.CIRCLE)
	)
	B1_Shooter.RNG = RNG
	B1_Shooter.rotation_random = true
	B1_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.MEDIUM_CYAN
		])
	]
	BossBlue.add_child(B1_Shooter)
	
	BossRed = BOSS.instantiate()
	BossRed.toggle_bomb_immunity()
	BossRed.set_sprite(SPRITE)
	BossRed.special_function("change_base_color", [Color(1, 0, 0, 1)])
	BossRed.disable()
	ParticleRed = HELPER_07.instantiate()
	ParticleRed.set_color(Color(1, 0, 0, 1))
	BossRed.add_child(ParticleRed)
	MarkerRed = HELPER_08.instantiate()
	MarkerRed.set_sprite(MARKER_RED)
	BossRed.add_child(MarkerRed)
	GlobalStage.request_add_object.emit(BossRed)
	
	A2_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A2_Shooter.RNG = RNG
	A2_Shooter.rotation_random = true
	A2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	BossRed.add_child(A2_Shooter)
	
	B2_Shooter = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(B2_layout_spawner_count)
	)
	B2_Bullets = RowData_Column.new([
		ColumnData_Laser.new([
			LaserData.new(10.0, LaserData.COLOR.RED)
		])
	])
	BossRed.add_child(B2_Shooter)
	
	BossGreen = BOSS.instantiate()
	BossGreen.toggle_bomb_immunity()
	BossGreen.set_sprite(SPRITE)
	BossGreen.special_function("change_base_color", [Color(0, 1, 0, 1)])
	BossGreen.disable()
	ParticleGreen = HELPER_07.instantiate()
	ParticleGreen.set_color(Color(0, 1, 0, 1))
	BossGreen.add_child(ParticleGreen)
	MarkerGreen = HELPER_08.instantiate()
	MarkerGreen.set_sprite(MARKER_GREEN)
	BossGreen.add_child(MarkerGreen)
	GlobalStage.request_add_object.emit(BossGreen)
	
	A3_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A3_Shooter.RNG = RNG
	A3_Shooter.rotation_random = true
	A3_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_GREEN
			])
		])
	]
	BossGreen.add_child(A3_Shooter)
	
	B3_Shooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(B3_layout_spawner_count),
		B3_ARROW_SIZE, B3_ARROW_LENGTH, B3_ARROW_WIDTH, 
		B3_ARROW_DISPLACEMENT,
		true
	)
	B3_Shooter.RNG = RNG
	B3_Shooter.rotation_random = true
	B3_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_GREEN
			])
		])
	]
	BossGreen.add_child(B3_Shooter)
	
	BossYellow = BOSS.instantiate()
	BossYellow.toggle_bomb_immunity()
	BossYellow.set_sprite(SPRITE)
	BossYellow.special_function("change_base_color", [Color(1, 1, 0, 1)])
	BossYellow.disable()
	ParticleYellow = HELPER_07.instantiate()
	ParticleYellow.set_color(Color(1, 1, 0, 1))
	BossYellow.add_child(ParticleYellow)
	MarkerYellow = HELPER_08.instantiate()
	MarkerYellow.set_sprite(MARKER_YELLOW)
	BossYellow.add_child(MarkerYellow)
	GlobalStage.request_add_object.emit(BossYellow)
	
	A4_Shooter = GlobalShooter.create_basic_shooter(A_layout_spawner_count)
	A4_Shooter.RNG = RNG
	A4_Shooter.rotation_random = true
	A4_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_YELLOW
			])
		])
	]
	BossYellow.add_child(A4_Shooter)
	
	B4_Shooter = GlobalShooter.create_basic_shooter(
		B4_layout_spawner_count, 
		B4_layout_column_count, B4_LAYOUT_COLUMN_RANGE
	)
	B4_Shooter.RNG = RNG
	B4_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_YELLOW
			])
		])
	]
	BossYellow.add_child(B4_Shooter)
	
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
	
	Boss.hide()
	Boss.disable()
	ParticleWhite.start()
	
	BossBlue.position = Boss.position
	BossBlue.show()
	
	BossRed.position = Boss.position
	BossRed.show()
	
	BossGreen.position = Boss.position
	BossGreen.show()
	
	BossYellow.position = Boss.position
	BossYellow.show()
	
	stopped = false
	spell_started.emit()
	
	change_target()
	move()


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
	A1_Shooter.disable()
	A2_Shooter.disable()
	A3_Shooter.disable()
	A4_Shooter.disable()
	B1_Shooter.disable()
	B2_Shooter.disable()
	B3_Shooter.disable()
	B4_Shooter.disable()
	
	ParticleBlue.start()
	ParticleRed.start()
	ParticleGreen.start()
	ParticleYellow.start()
	
	Boss.enable()
	BossBlue.queue_free()
	BossRed.queue_free()
	BossGreen.queue_free()
	BossYellow.queue_free()
	
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
		attack_a()
		phase = 0


func attack_a():
	if not BossBlueActive:
		BossBlue.custom_animation("AttackA")
		A1_Shooter.fire_round(
			A1_Bullets,
			A_fire_count, A_FIRE_DURATION,
			A_BULLET_SPEED
		)
	else:
		BossBlue.custom_animation("AttackB")
		B1_Shooter.fire_round_full(
			B1_Bullets,
			B1_fire_count, B_FIRE_DURATION,
			0, 0,
			B1_TWEEN_TIME, B1_TWEEN_MAX_ROTATION, B1_TWEEN_MIN_ROTATION,
			true
		)
	
	if not BossRedActive:
		BossRed.custom_animation("AttackA")
		A2_Shooter.fire_round(
			A2_Bullets,
			A_fire_count, A_FIRE_DURATION,
			A_BULLET_SPEED
		)
	else:
		BossRed.custom_animation("AttackB")
		B2_Shooter.rotation_speed = B2_SHOOTER_ROTATION_SPEED_MAX * (TAU / 360) * B2_direction
		B2_Shooter.create_tween().tween_property(
			B2_Shooter, 
			"rotation_speed", 
			B2_SHOOTER_ROTATION_SPEED_MIN * (TAU / 360) * B2_direction, 
			B2_SHOOTER_ROTATION_TIME
		)
		B2_Shooter.fire_round(
			B2_Bullets, B2_LASER_DURATION, B2_LASER_DELAY
		)
		B2_direction *= -1
	
	if not BossGreenActive:
		BossGreen.custom_animation("AttackA")
		A3_Shooter.fire_round(
			A3_Bullets,
			A_fire_count, A_FIRE_DURATION,
			A_BULLET_SPEED
		)
	else:
		BossGreen.custom_animation("AttackB")
		B3_Shooter.fire_round(
			B3_Bullets, 
			B3_fire_count, B_FIRE_DURATION, 
			B3_BULLET_SPEED
		)
	
	if not BossYellowActive:
		BossYellow.custom_animation("AttackA")
		A4_Shooter.fire_round(
			A4_Bullets,
			A_fire_count, A_FIRE_DURATION,
			A_BULLET_SPEED
		)
	else:
		BossYellow.custom_animation("AttackB")
		B4_Shooter.rotation_speed = B4_SHOOTER_ROTATION_SPEED * B4_direction
		B4_Shooter.fire_round(
			B4_Bullets,
			B4_fire_count, B_FIRE_DURATION,
			B4_BULLET_SPEED
		)
		B4_direction *= -1
	
	await Boss.create_waiter(A_FIRE_DURATION).finished
	
	BossBlue.return_animation()
	BossRed.return_animation()
	BossGreen.return_animation()
	BossYellow.return_animation()
	await Boss.create_waiter(WAIT_AFTER_ATTACK).finished
	
	change_target()
	move()


func move() -> void:
	var rand_pos_blue   = get_rand_position([])
	var rand_pos_red    = get_rand_position([rand_pos_blue])
	var rand_pos_green  = get_rand_position([rand_pos_blue, rand_pos_red])
	var rand_pos_yellow = get_rand_position([rand_pos_blue, rand_pos_red, rand_pos_green])
	
	BossBlue.move_boss(rand_pos_blue, MOVE_TIME)
	BossRed.move_boss(rand_pos_red, MOVE_TIME)
	BossGreen.move_boss(rand_pos_green, MOVE_TIME)
	await BossYellow.move_boss(rand_pos_yellow, MOVE_TIME).finished
	await Boss.create_waiter(WAIT_AFTER_MOVE).finished
	
	next_phase()


func change_target():
	var target = RNG.randi_range(0, 3)
	match target:
		TARGET.BLUE:
			BossBlueActive   = true
			BossRedActive    = false
			BossGreenActive  = false
			BossYellowActive = false
			BossBlue         .enable_collider()
			BossRed          .disable_collider()
			BossGreen        .disable_collider()
			BossYellow       .disable_collider()
			MarkerBlue       .turn_on()
			MarkerRed        .turn_off()
			MarkerGreen      .turn_off()
			MarkerYellow     .turn_off()
		TARGET.RED:
			BossBlueActive   = false
			BossRedActive    = true
			BossGreenActive  = false
			BossYellowActive = false
			BossBlue         .disable_collider()
			BossRed          .enable_collider()
			BossGreen        .disable_collider()
			BossYellow       .disable_collider()
			MarkerBlue       .turn_off()
			MarkerRed        .turn_on()
			MarkerGreen      .turn_off()
			MarkerYellow     .turn_off()
		TARGET.GREEN:
			BossBlueActive   = false
			BossRedActive    = false
			BossGreenActive  = true
			BossYellowActive = false
			BossBlue         .disable_collider()
			BossRed          .disable_collider()
			BossGreen        .enable_collider()
			BossYellow       .disable_collider()
			MarkerBlue       .turn_off()
			MarkerRed        .turn_off()
			MarkerGreen      .turn_on()
			MarkerYellow     .turn_off()
		TARGET.YELLOW:
			BossBlueActive   = false
			BossRedActive    = false
			BossGreenActive  = false
			BossYellowActive = true
			BossBlue         .disable_collider()
			BossRed          .disable_collider()
			BossGreen        .disable_collider()
			BossYellow       .enable_collider()
			MarkerBlue       .turn_off()
			MarkerRed        .turn_off()
			MarkerGreen      .turn_off()
			MarkerYellow     .turn_on()


func get_rand_position(previous:Array[Vector2]) -> Vector2:
	var rand_position:Vector2 = Vector2.ZERO
	
	var retry = true
	var tries:int = 120
	while retry and tries > 0:
		retry = false
		tries -= 1
		rand_position = GlobalStage.random_position(
			MOVE_BOUND_RIGHT, MOVE_BOUND_LEFT, MOVE_BOUND_TOP, MOVE_BOUND_BOTTOM, 
			Boss.position, MOVE_DISTANCE, RNG
		)
		
		for other_position in previous:
			if rand_position.distance_squared_to(other_position) < 10000: 
				retry = true
	
	return rand_position




func _on_Boss_tree_exiting():
	stopped = true
