extends Node2D

var main_shooter:Shooter_Basic
var main_bullets:Array[RowData_Column]

var spawners:Array = []
var RNG:RandomNumberGenerator

var activated:bool = false
var disabled:bool = false

const HELPER_06 := preload("res://Game/Entities/Boss/BossResources/Remilia/SpellResources/RemiliaHelper06.tscn")




func build(
		primary_layout_line_count:int,
		secondary_shooter_rotation_range:float
	) -> void:
	
	%Guide.modulate.a = 0.0
	
	var angle = RNG.randf_range(0, TAU)
	var angle_step = PI / primary_layout_line_count
	for _i in primary_layout_line_count:
		var line = Line2D.new()
		line.add_point(Vector2(-1000, 0), 0)
		line.add_point(Vector2( 1000, 0), 1)
		line.width = 12
		line.default_color = Color(1, 0, 0, 1)
		line.rotation = angle
		%Guide.add_child(line)
		
		angle += angle_step
	
	var primary_layout_spawner_count = primary_layout_line_count * 2
	var new_angle_step = TAU / primary_layout_spawner_count
	for _i in primary_layout_spawner_count:
		var marker = Marker2D.new()
		marker.rotation = angle
		spawners.append(marker)
		self.add_child(marker)
		
		angle += new_angle_step
	
	main_shooter = GlobalShooter.create_basic_shooter(primary_layout_spawner_count)
	main_shooter.rotation = angle
	main_shooter.rotation_random = true
	main_shooter.rotation_random_range = Vector2(
		angle - deg_to_rad(secondary_shooter_rotation_range),
		angle + deg_to_rad(secondary_shooter_rotation_range)
	)
	main_shooter.RNG = RNG
	main_bullets = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				GlobalShooter.BRIGHT_RED
			])
		])
	]
	
	self.add_child(main_shooter)


func fire(
		primary_bullet_speed:float,
		secondary_fire_count:int,
		secondary_bullet_speed:float,
		secondary_bullet_speed_range:float
	) -> void:
	
	if disabled:
		return
	
	if !activated:
		activated = true
		var ActivatedTween = self.create_tween()
		ActivatedTween.tween_property(%Guide, "modulate:a", 0.4, 0.4)
		return
	
	%Sound.play()
	for spawner in spawners:
		var bullet = HELPER_06.instantiate()
		bullet.transform = spawner.global_transform
		bullet.build(
			Vector2.RIGHT.rotated(spawner.global_rotation) * primary_bullet_speed
		)
		GlobalStage.request_add_object.emit(bullet)
	
	main_shooter.fire_round(
		main_bullets,
		secondary_fire_count, 0,
		secondary_bullet_speed, secondary_bullet_speed_range
	)


func disable() -> void:
	var ActivatedTween = self.create_tween()
	ActivatedTween.tween_property(%Guide, "modulate:a", 0, 0.4)
	
	disabled = true
