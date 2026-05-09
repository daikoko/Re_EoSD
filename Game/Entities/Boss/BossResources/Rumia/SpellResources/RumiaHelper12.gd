extends Node2D

const HELPER_04 := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/RumiaHelper04.tscn")
const BEAM := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaLaser.png")
const GLOW := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaLaserGlow.png")

const ARC_LENGTH := 60.0
const TIME_TOTAL := 0.8
const TIME_START := 0.4
const TIME_END := 0.2

const ROUND_COUNT := 8
const FIRE_COUNT := 8

const LAYOUT_SPAWNER_COUNT := 3
const LAYOUT_SHOT_RANGE := 60.0
const BULLET_SPEED := 0
const LINEAR_DELAY := 1.2
const LINEAR_TIME := 0.8
const LINEAR_SPEED := 160.0

var RNG:RandomNumberGenerator
var MainShooter:Shooter_Linear
var Bullets:Array[RowData_Column]
var Canvas:Node2D
var Beam:Node2D
var Glow:Node2D

var direction:int = 1

signal shooting_start
signal shooting_finished




func _ready() -> void:
	%Warning.value = (ARC_LENGTH / 360) * 100
	
	%Warning.pivot_offset = (%Warning.size / 2)
	%Warning.position = - (%Warning.size / 2)
	%Warning.rotation = (PI / 2) - (deg_to_rad(ARC_LENGTH) / 2)
	%Warning.modulate.a = 0.4
	
	%Beam.scale.y = 0
	%Beam.hide()
	%Warning.hide()
	
	MainShooter = GlobalShooter.create_linear_shooter(
		LAYOUT_SPAWNER_COUNT,
		1, 360,
		LAYOUT_SHOT_RANGE,
		0
	)
	MainShooter.RNG = RNG
	Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	%PathFollow.add_child(MainShooter)
	
	Canvas = HELPER_04.instantiate()
	GlobalStage.request_add_object.emit(Canvas)
	
	Beam = Sprite2D.new()
	Beam.texture = BEAM
	Canvas.add_spawner(Beam)
	
	Glow = Sprite2D.new()
	Glow.texture = GLOW
	Glow.modulate = Color(2, 1, 1, 1)
	Canvas.add_sprite(Glow)


func _process(_delta: float) -> void:
	MainShooter.global_scale = Vector2.ONE
	
	Beam.global_transform = %Beam.global_transform
	Glow.global_transform = %Beam.global_transform




func fire():
	var center = (GlobalStage.VIEWPORT_SIZE / 2) + (Vector2.DOWN * 200)
	var vector = center - self.global_position
	var angle = RNG.randf_range(
		vector.angle() - deg_to_rad(30),
		vector.angle() + deg_to_rad(30)
	)
	
	%Pointer.rotation = angle
	%Animator.play("Blink")
	await %Animator.animation_finished
	
	shooting_start.emit()
	
	grow()
	%Line.rotation = - deg_to_rad(ARC_LENGTH / 2) * direction
	
	MainShooter.rotation = - deg_to_rad(90) * direction
	%FireTimer.wait_time = TIME_TOTAL / ROUND_COUNT
	%FireTimer.start()
	
	%Sound.play()
	var SweepTween = create_tween()
	SweepTween.tween_property(%Line, "rotation", deg_to_rad(ARC_LENGTH / 2) * direction, TIME_TOTAL)
	await SweepTween.finished
	
	%Collider.disable()
	%FireTimer.stop()
	
	direction *= -1
	shooting_finished.emit()


func grow():
	%Beam.scale.y = 0
	
	var GrowTween = create_tween()
	GrowTween.tween_property(%Beam, "scale:y", 1.0, TIME_START)
	GrowTween.tween_interval(TIME_TOTAL - TIME_START - TIME_END)
	GrowTween.tween_property(%Beam, "scale:y", 0, TIME_END)
	await GrowTween.finished


func disable():
	queue_free()




func _on_FireTimer_timeout() -> void:
	%PathFollow.progress_ratio = 0
	var step = 1.0 / FIRE_COUNT
	for _i in FIRE_COUNT:
		MainShooter.fire_round(
			Bullets,
			1, 0,
			BULLET_SPEED, 0,
			0, 0,
			LINEAR_DELAY,
			LINEAR_TIME,
			LINEAR_SPEED
		)
		
		%PathFollow.progress_ratio += step
		MainShooter.rotation += - (TAU / (ROUND_COUNT * FIRE_COUNT)) * direction


func _on_Collider_collider_entered(_other: Collider, other_identity: String) -> void:
	if (
			other_identity == "PlayerHitbox" and 
			not GlobalStage.is_current_player_bomb() and 
			not GlobalStage.is_current_stage_clear()
		):
		
		GlobalPlayer.player_hit.emit()
