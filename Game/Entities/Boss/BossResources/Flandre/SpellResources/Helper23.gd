extends Node2D

var SelfTween:Tween
var RNG:RandomNumberGenerator

var F1_Shooter:Shooter_Basic
var F1_Bullets:Array[RowData_Column]

var F2_Shooter:Shooter_Basic
var F2_Bullets:Array[RowData_Column]

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
		F1_layout_spawner_count:int,
		F1_layout_column_count:int,
		F1_layout_column_range:float,
		F1_fire_count:int,
		F1_fire_duration:float,
		F1_bullet_speed:float,
		F1_spawn_stack_count:int,
		F1_spawn_stack_speed:float,
		F2_layout_spawner_count:float,
		F2_fire_count:int,
		F2_fire_duration:float,
		F2_bullet_speed:float,
		F2_bullet_speed_range:float
	):
	
	disabled = false
	
	F1_Shooter = GlobalShooter.create_basic_shooter(
		F1_layout_spawner_count,
		F1_layout_column_count, F1_layout_column_range
	)
	F1_Shooter.RNG = RNG
	F1_Shooter.rotation = RNG.randf_range(0, TAU)
	F1_Shooter.rotation_speed = (PI / F1_layout_spawner_count) / (F1_fire_duration / F1_fire_count)
	F1_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.KNIFE_RED
			])
		])
	]
	self.add_child(F1_Shooter)
	
	F2_Shooter = GlobalShooter.create_basic_shooter(F2_layout_spawner_count)
	F2_Shooter.RNG = RNG
	F2_Shooter.rotation_random = true
	F2_Bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.SMALL_RED
			])
		])
	]
	self.add_child(F2_Shooter)
	
	SelfTween = set_tween()
	SelfTween.tween_property(self, "mod_act", 1, 1.0)
	await SelfTween.finished
	
	F1_Shooter.fire_round_stack(
		F1_Bullets,
		F1_fire_count, F1_fire_duration,
		F1_bullet_speed, 0,
		0, 0,
		F1_spawn_stack_count, F1_spawn_stack_speed
	)
	F2_Shooter.fire_round(
		F2_Bullets,
		F2_fire_count, F2_fire_duration,
		F2_bullet_speed, F2_bullet_speed_range
	)
	await F1_Shooter.finished_round
	
	SelfTween = set_tween()
	SelfTween.tween_interval(1.8)
	await SelfTween.finished
	
	finished_round.emit()


func disable():
	if disabled: return
	disabled = true
	
	F1_Shooter.disable()
	F2_Shooter.disable()
	
	SelfTween = set_tween()
	SelfTween.tween_property(self, "mod_act", 0, 0.6)




func set_tween() -> Tween:
	if SelfTween: SelfTween.kill()
	
	return self.create_tween()




func _on_GlobalPlayer_player_used_bomb(_spellname):
	self.create_tween().tween_property(self, "mod_bomb", 0, 0.4)


func _on_GlobalPlayer_player_used_bomb_stop():
	self.create_tween().tween_property(self, "mod_bomb", 1, 0.4)
