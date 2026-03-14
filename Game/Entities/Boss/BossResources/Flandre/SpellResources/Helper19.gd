extends Node2D

var SelfTween:Tween
var RNG:RandomNumberGenerator

var B1_Shooter:Shooter_Basic
var B1_Bullets:Array[RowData_Column]

var B2_Shooter:Shooter_Tween
var B2_Bullets:Array[RowData_Bullet]

var time:float
var disabled:bool

signal finished_round()




func _ready() -> void:
	%Sprite.modulate.a = 0
	
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_used_bomb)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalPlayer_player_used_bomb_stop)


func _process(delta:float) -> void:
	%Sprite.rotation = (PI / 12.0) * sin(1.2 * time)
	
	time += delta




func start(
		B1_layout_spawner_count:int,
		B1_fire_count:int,
		B1_fire_duration:float,
		B1_bullet_speed:float,
		B2_layout_spawner_count:int,
		B2_fire_count:int,
		B2_fire_duration:float,
		B2_tween_time:float,
		B2_tween_rotation_max:float,
		B2_tween_rotation_min:float	
	):
	
	B1_Shooter = GlobalShooter.create_basic_shooter(
		B1_layout_spawner_count,
	)
	B1_Shooter.RNG = RNG
	B1_Shooter.rotation = RNG.randf_range(0, TAU)
	B1_Shooter.rotation_speed = (PI / B1_layout_spawner_count) / (B1_fire_duration / B1_fire_count)
	B1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	self.add_child(B1_Shooter)
	
	B2_Shooter = GlobalShooter.create_tween_shooter(
		GlobalShooter.build_shape(B2_layout_spawner_count)
	)
	B2_Shooter.RNG = RNG
	B2_Shooter.rotation_random = true
	B2_Bullets = [
		RowData_Bullet.new([
			GlobalShooter.MEDIUM_RED
		])
	]
	self.add_child(B2_Shooter)
	
	SelfTween = set_tween()
	SelfTween.tween_property(%Sprite, "modulate:a", 1, 1.0)
	await SelfTween.finished
	
	B1_Shooter.fire_round(
		B1_Bullets,
		B1_fire_count, B1_fire_duration,
		B1_bullet_speed
	)
	B2_Shooter.fire_round_full(
		B2_Bullets,
		B2_fire_count, B2_fire_duration,
		0, 0,
		B2_tween_time, B2_tween_rotation_max, B2_tween_rotation_min,
		false, [],
		1
	)
	await B1_Shooter.finished_round
	
	SelfTween = set_tween()
	SelfTween.tween_interval(1.8)
	await SelfTween.finished
	
	finished_round.emit()


func disable():
	if disabled: return
	disabled = true
	
	B1_Shooter.disable()
	B2_Shooter.disable()
	
	SelfTween = set_tween()
	SelfTween.tween_property(%Sprite, "modulate:a", 0, 0.6)




func set_tween() -> Tween:
	if SelfTween: SelfTween.kill()
	
	return self.create_tween()




func _on_GlobalPlayer_player_used_bomb(_spellname):
	if disabled: return
	
	SelfTween = set_tween()
	SelfTween.tween_property(%Sprite, "modulate:a", 0, 0.4)


func _on_GlobalPlayer_player_used_bomb_stop():
	if disabled: return
	
	SelfTween = set_tween()
	SelfTween.tween_property(%Sprite, "modulate:a", 1, 0.4)
