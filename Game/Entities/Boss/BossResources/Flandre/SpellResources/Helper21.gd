extends Node2D

var SelfTween:Tween
var RNG:RandomNumberGenerator

var D1_Shooter_a:Shooter_Basic
var D1_Shooter_b:Shooter_Basic
var D1_Bullets:Array[RowData_Column]

var D2_Shooter:Shooter_Basic
var D2_Bullets:Array[RowData_Column]

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
		D1_layout_spawner_count:float,
		D1_fire_count:int,
		D1_fire_duration:float,
		D1_bullet_speed:float,
		D1_shooter_rotation_speed:float,
		D2_layout_spawner_count:float,
		D2_fire_count:int,
		D2_round_count:int,
		D2_fire_duration:float,
		D2_bullet_speed:float,
		D2_bullet_speed_range:float,
	):
	
	D1_Shooter_a = GlobalShooter.create_basic_shooter(D1_layout_spawner_count)
	D1_Shooter_b = GlobalShooter.create_basic_shooter(D1_layout_spawner_count)
	D1_Shooter_a.rotation = RNG.randf_range(0, TAU)
	D1_Shooter_b.rotation = D1_Shooter_a.rotation
	D1_Shooter_a.rotation_speed = deg_to_rad(D1_shooter_rotation_speed)
	D1_Shooter_b.rotation_speed = -deg_to_rad(D1_shooter_rotation_speed)
	D1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	self.add_child(D1_Shooter_a)
	self.add_child(D1_Shooter_b)
	
	D2_Shooter = GlobalShooter.create_basic_shooter(D2_layout_spawner_count)
	D2_Shooter.RNG = RNG
	D2_Shooter.rotation_random = true
	D2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	self.add_child(D2_Shooter)
	
	SelfTween = set_tween()
	SelfTween.tween_property(%Sprite, "modulate:a", 1, 1.0)
	await SelfTween.finished
	
	D1_Shooter_a.fire_round(
		D1_Bullets,
		D1_fire_count, D1_fire_duration,
		D1_bullet_speed
	)
	D1_Shooter_b.fire_round(
		D1_Bullets,
		D1_fire_count, D1_fire_duration,
		D1_bullet_speed
	)
	for _i in D2_round_count:
		D2_Shooter.fire_round(
			D2_Bullets,
			D2_fire_count, D2_fire_duration,
			D2_bullet_speed, D2_bullet_speed_range
		)
		await self.create_tween().tween_interval(D2_fire_duration / D2_round_count).finished
	
	SelfTween = set_tween()
	SelfTween.tween_interval(1.8)
	await SelfTween.finished
	
	finished_round.emit()


func disable():
	if disabled: return
	disabled = true
	
	D1_Shooter_a.disable()
	D1_Shooter_b.disable()
	D2_Shooter.disable()
	
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
