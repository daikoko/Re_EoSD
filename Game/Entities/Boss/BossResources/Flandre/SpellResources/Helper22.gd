extends Node2D

var SelfTween:Tween
var RNG:RandomNumberGenerator

var E1_Shooter_a:Shooter_Laser
var E1_Shooter_b:Shooter_Laser
var E1_Lasers:RowData_Column

var E2_Shooter:Shooter_Basic
var E2_Bullets:Array[RowData_Column]

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
		E1_layout_spawner_count:int,
		E1_laser_delay:float,
		E1_laser_duration:float,
		E1_shooter_rotation_speed:float,
		E1_shooter_fire_count:int,
		E1_shooter_delay:float,
		E2_layout_spawner_count:int,
		E2_layout_column_count:int,
		E2_layout_column_range:float,
		E2_fire_count:int,
		E2_fire_duration:float,
		E2_bullet_speed:float,
		E2_bullet_speed_range:float,
		E2_shooter_rotation_speed:float
	):
	
	E1_Shooter_a = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(E1_layout_spawner_count)
	)
	E1_Shooter_b = GlobalShooter.create_laser_shooter(
		GlobalShooter.build_basic(E1_layout_spawner_count)
	)
	E1_Lasers = RowData_Column.new([
		ColumnData_Laser.new([
			LaserData.new(16.0, LaserData.COLOR.RED)
		])
	])
	self.add_child(E1_Shooter_a)
	self.add_child(E1_Shooter_b)
	
	E2_Shooter = GlobalShooter.create_basic_shooter(
		E2_layout_spawner_count,
		E2_layout_column_count, deg_to_rad(E2_layout_column_range)
	)
	E2_Shooter.RNG = RNG
	E2_Shooter.rotation = RNG.randf_range(0, TAU)
	E2_Shooter.rotation_speed = deg_to_rad(E2_shooter_rotation_speed)
	E2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	self.add_child(E2_Shooter)
	
	SelfTween = set_tween()
	SelfTween.tween_property(%Sprite, "modulate:a", 1, 1.0)
	await SelfTween.finished
	
	E2_Shooter.fire_round(
		E2_Bullets,
		E2_fire_count, E2_fire_duration,
		E2_bullet_speed, E2_bullet_speed_range
	)
	
	E1_Shooter_a.rotation_speed = deg_to_rad(E1_shooter_rotation_speed)
	E1_Shooter_b.rotation_speed = -deg_to_rad(E1_shooter_rotation_speed)
	for _i in E1_shooter_fire_count:
		E1_Shooter_a.fire_round(
			E1_Lasers,
			E1_laser_duration, E1_laser_delay
		)
		await self.create_tween().tween_interval(E1_shooter_delay).finished
		
		E1_Shooter_b.fire_round(
			E1_Lasers,
			E1_laser_duration, E1_laser_delay
		)
		await self.create_tween().tween_interval(E1_shooter_delay).finished
	
	SelfTween = set_tween()
	SelfTween.tween_interval(1.8)
	await SelfTween.finished
	
	finished_round.emit()


func disable():
	if disabled: return
	disabled = true
	
	E1_Shooter_a.disable()
	E1_Shooter_b.disable()
	E2_Shooter.disable()
	
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
