extends Node2D

var SelfTween:Tween
var RNG:RandomNumberGenerator

var C1_Shooter:Shooter_Arrow
var C1_Bullets:Array[RowData_Column]

var C2_Shooter:Shooter_Basic
var C2_Bullets:Array[RowData_Column]

var time:float
var disabled:bool = true

var mod_act:float  = 0
var mod_bomb:float = 1

signal finished_round()




func _ready() -> void:
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_used_bomb)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalPlayer_player_used_bomb_stop)


func _process(delta:float) -> void:
	%Sprite.rotation = (PI / 12.0) * sin(1.2 * time)
	
	time += delta
	%Sprite.modulate.a = mod_act * mod_bomb




func start(
		C1_layout_spawner_count:int,
		C1_arrow_size:int,
		C1_arrow_lenth:float,
		C1_arrow_width:float,
		C1_arrow_displacement:float,
		C1_fire_count:int,
		C1_fire_duration:float,
		C1_bullet_speed:float,
		C1_rotation_speed:float,
		C2_layout_spawner_count:float,
		C2_fire_count:int,
		C2_fire_duration:float,
		C2_bullet_speed:float,
		C2_bullet_speed_range:float
	):
	
	disabled = false
	
	C1_Shooter = GlobalShooter.create_arrow_shooter(
		GlobalShooter.build_basic(C1_layout_spawner_count),
		C1_arrow_size, C1_arrow_lenth, C1_arrow_width,
		C1_arrow_displacement
	)
	C1_Shooter.RNG = RNG
	C1_Shooter.rotation = RNG.randf_range(0, TAU)
	C1_Shooter.rotation_speed = deg_to_rad(C1_rotation_speed)
	C1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SPADE_RED
			])
		])
	]
	self.add_child(C1_Shooter)
	
	C2_Shooter = GlobalShooter.create_basic_shooter(C2_layout_spawner_count)
	C2_Shooter.RNG = RNG
	C2_Shooter.rotation_random = true
	C2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.STONE_RED
			])
		])
	]
	self.add_child(C2_Shooter)
	
	SelfTween = set_tween()
	SelfTween.tween_property(self, "mod_act", 1, 1.0)
	await SelfTween.finished
	
	C1_Shooter.fire_round(
		C1_Bullets,
		C1_fire_count, C1_fire_duration,
		C1_bullet_speed
	)
	C2_Shooter.fire_round(
		C2_Bullets,
		C2_fire_count, C2_fire_duration,
		C2_bullet_speed, C2_bullet_speed_range
	)
	await C1_Shooter.finished_round
	
	SelfTween = set_tween()
	SelfTween.tween_interval(1.8)
	await SelfTween.finished
	
	finished_round.emit()


func disable():
	if disabled: return
	disabled = true
	
	C1_Shooter.disable()
	C2_Shooter.disable()
	
	SelfTween = set_tween()
	SelfTween.tween_property(self, "mod_act", 0, 0.6)




func set_tween() -> Tween:
	if SelfTween: SelfTween.kill()
	
	return self.create_tween()




func _on_GlobalPlayer_player_used_bomb(_spellname):
	self.create_tween().tween_property(self, "mod_bomb", 0, 0.4)


func _on_GlobalPlayer_player_used_bomb_stop():
	self.create_tween().tween_property(self, "mod_bomb", 1, 0.4)
