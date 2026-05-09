extends Node2D

const HELPER_04 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper04.tscn")
const HELPER_22 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper22.tscn")

var A_Shooter:Shooter_Basic
var A_Bullets:Array[RowData_Column]
const A_LAYOUT_SPAWNER_COUNT := 2
const A_LAYOUT_COLUMN_COUNT := 6
const A_LAYOUT_COLUMN_RANGE := 10
const A_FIRE_COUNT := 8
const A_FIRE_DURATION := 1.0
const A_BULLET_SPEED := 120.0
const A_BULLET_SPEED_RANGE := 30.0
const A_SHOOTER_ROTATION_SPEED := 16.0

var B_Shooter:Shooter_Tween
var B_Bullets:Array[RowData_Bullet]
const B_LAYOUT_SPAWNER_COUNT := 10
const B_FIRE_COUNT := 1
const B_FIRE_DURATON = 2.0
const B_TWEEN_TIME := 10.0
const B_TWEEN_ROTATION_MIN := 6.0
const B_TWEEN_ROTATION_MAX := 12.0
const B_SHOOTER_ROTATION_SPEED := 60.0

var C_Shooter:Shooter_Linear
const C_LINEAR_DELAY := 0.2
const C_LINEAR_TIME := 2.0
const C_LINEAR_DIR_CHANGE := -30.0

const C_SHOT_INTERVAL := 2.0

var RNG:RandomNumberGenerator
var DarkTween:Tween
var Canvas:Node2D
var disabled:bool

var stopped:bool


func _ready():
	%Darkness.scale = Vector2.ZERO
	%Darkness.modulate.a = 1
	%DarknessPlayer.modulate.a = 0
	GlobalPlayer.player_used_bomb.connect(_on_GlobalStage_player_used_bomb)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalStage_player_used_bomb_stop)
	
	Canvas = HELPER_04.instantiate()
	GlobalStage.request_add_object.emit(Canvas)
	
	%Center.hide()
	
	A_Shooter = GlobalShooter.create_basic_shooter(
		A_LAYOUT_SPAWNER_COUNT,
		A_LAYOUT_COLUMN_COUNT, A_LAYOUT_COLUMN_RANGE
	)
	A_Shooter.RNG = RNG
	A_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_MAGENTA
			])
		])
	]
	%Center.add_child(A_Shooter)
	
	B_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(
			B_LAYOUT_SPAWNER_COUNT,
			0, Vector2.ONE,
			0
		)
	)
	B_Shooter.flash_time = 0
	B_Shooter.RNG = RNG
	B_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.MEDIUM_MAGENTA
		])
	]
	%Center.add_child(B_Shooter)
	
	C_Shooter = GlobalShooter.create_linear_shooter(
		A_LAYOUT_SPAWNER_COUNT,
		A_LAYOUT_COLUMN_COUNT, A_LAYOUT_COLUMN_RANGE
	)
	C_Shooter.RNG = RNG
	%Center.add_child(C_Shooter)


func _process(delta:float):
	%Sprite02.rotation += deg_to_rad(  2.0) * delta
	%Sprite03.rotation += deg_to_rad(- 3.0) * delta
	%Sprite04.rotation += deg_to_rad(  4.0) * delta




func start():
	DarkTween = set_tween()
	DarkTween.tween_property(%Darkness, "scale",      Vector2.ONE * 20, 1.4)
	DarkTween.tween_interval(                                           0.2)
	await DarkTween.finished
	
	%Center.show()
	%DarknessPlayer.modulate.a = 1.0
	DarkTween = set_tween()
	DarkTween.tween_property(%Darkness, "modulate:a", 0, 1.0)
	await DarkTween.finished
	
	attack_a()
	attack_b()
	attack_c()


func attack_a():
	A_Shooter.rotation = RNG.randf_range(0, TAU)
	C_Shooter.rotation = A_Shooter.rotation
	while not stopped:
		A_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED)
		A_Shooter.fire_round(
			A_Bullets,
			A_FIRE_COUNT, A_FIRE_DURATION,
			A_BULLET_SPEED, A_BULLET_SPEED_RANGE
		)
		
		C_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED)
		C_Shooter.fire_round(
			A_Bullets,
			A_FIRE_COUNT, A_FIRE_DURATION,
			A_BULLET_SPEED, A_BULLET_SPEED_RANGE,
			0, 0,
			C_LINEAR_DELAY, C_LINEAR_TIME, 
			0,
			C_LINEAR_DIR_CHANGE
		)
		
		await A_Shooter.finished_round


func attack_b():
	B_Shooter.rotation = RNG.randf_range(0, TAU)
	while not stopped:
		B_Shooter.rotation_speed = deg_to_rad(A_SHOOTER_ROTATION_SPEED)
		B_Shooter.fire_round_full(
			B_Bullets,
			B_FIRE_COUNT, B_FIRE_DURATON,
			0, 0, 
			B_TWEEN_TIME, B_TWEEN_ROTATION_MAX, B_TWEEN_ROTATION_MIN,
			true
		)
		await B_Shooter.finished_round


func attack_c():
	while not stopped:
		var rand_pos:Vector2
		for _i in 100:
			rand_pos = Vector2(
				RNG.randf_range(40, 660),
				RNG.randf_range(60, 720)
			)
			
			if GlobalPlayer.distance_to_player(rand_pos) > 500:
				break
		
		var shot = HELPER_22.instantiate()
		shot.RNG = RNG
		shot.position = rand_pos
		Canvas.add_spawner(shot)
		
		var sprite = shot.get_glow()
		sprite.modulate = Color(2, 1, 1, 1)
		Canvas.add_sprite(sprite)
		
		await create_tween().tween_interval(C_SHOT_INTERVAL).finished



func disable():
	stopped = true
	
	Canvas.queue_free()
	queue_free()


func set_tween() -> Tween:
	if DarkTween:
		DarkTween.kill()
	
	return self.create_tween().set_parallel(true)




func _on_GlobalStage_player_used_bomb(_spellname):
	if disabled: return
	
	DarkTween = set_tween()
	DarkTween.tween_property(%DarknessPlayer, "modulate:a", 0, 0.2)


func _on_GlobalStage_player_used_bomb_stop():
	if disabled: return
	
	DarkTween = set_tween()
	DarkTween.tween_property(%DarknessPlayer, "modulate:a", 1.0, 0.4)
