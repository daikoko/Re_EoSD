extends Node2D

var SelfTween:Tween
var RNG:RandomNumberGenerator

var G1_Shooter:Shooter_Basic
var G1_Bullets:Array[RowData_Column]

var G2_Shooter:Shooter_Basic
var G2_Bullets:Array[RowData_Column]

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
		G1_layout_spawner_count:float,
		G1_fire_count:int,
		G1_fire_duration:float,
		G1_bullet_speed:float,
		G1_shooter_rotation_speed:float,
		G2_layout_spawner_count:float,
		G2_fire_count:int,
		G2_fire_duration:float,
		G2_bullet_speed:float,
		G2_bullet_speed_range:float,
	):
	
	disabled = false
	
	G1_Shooter = GlobalShooter.create_basic_shooter(G1_layout_spawner_count)
	G1_Shooter.RNG = RNG
	G1_Shooter.rotation_speed = deg_to_rad(G1_shooter_rotation_speed)
	G1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.LARGE_RED
			])
		])
	]
	self.add_child(G1_Shooter)
	
	G2_Shooter = GlobalShooter.create_basic_shooter(G2_layout_spawner_count)
	G2_Shooter.RNG = RNG
	G2_Shooter.rotation_random = true
	G2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	self.add_child(G2_Shooter)
	
	SelfTween = set_tween()
	SelfTween.tween_property(self, "mod_act", 1, 1.0)
	await SelfTween.finished
	
	G1_Shooter.fire_round_stack(
		G1_Bullets,
		G1_fire_count, G1_fire_duration,
		G1_bullet_speed, 
	)
	G2_Shooter.fire_round(
		G2_Bullets,
		G2_fire_count, G2_fire_duration,
		G2_bullet_speed, G2_bullet_speed_range
	)
	await G1_Shooter.finished_round
	
	SelfTween = set_tween()
	SelfTween.tween_interval(1.8)
	await SelfTween.finished
	
	finished_round.emit()


func disable():
	if disabled: return
	disabled = true
	
	G1_Shooter.disable()
	G2_Shooter.disable()
	
	SelfTween = set_tween()
	SelfTween.tween_property(self, "mod_act", 0, 0.6)




func set_tween() -> Tween:
	if SelfTween: SelfTween.kill()
	
	return self.create_tween()




func _on_GlobalPlayer_player_used_bomb(_spellname):
	self.create_tween().tween_property(self, "mod_bomb", 0, 0.4)


func _on_GlobalPlayer_player_used_bomb_stop():
	self.create_tween().tween_property(self, "mod_bomb", 1, 0.4)
