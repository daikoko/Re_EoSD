extends Shooter
class_name Shooter_Basic

var RNG:RandomNumberGenerator = null

var spawner_map:Array = []
var column_count:int
var spawner_count:int

var rotation_speed:float = 0
var rotation_random:bool = false
var rotation_random_range:Vector2 = Vector2(0, TAU)

var flash_scale:float = 2.0
var flash_time:float = 0.2
var immunity_time:float = 0.1
var mute:bool = false

# var last_rot = 0.0
# var last_time = 0.0
# var frame_counter:int = 0

signal finished_row




func _process(delta):
	rotation += rotation_speed * delta
	# frame_counter += 1




func fire_round_stack(
		rows:Array[RowData_Column], 
		fire_count:int, fire_duration:float, 
		bullet_speed:float, bullet_speed_range:float=0,
		spawn_row_speed:float=0, spawn_spawner_speed:float=0, 
		spawn_stack_count:int=1, spawn_stack_speed:float=0
	) -> void:
	
	fire_round(
		rows, 
		fire_count, fire_duration,
		bullet_speed, bullet_speed_range,
		0, 0,
		0,
		spawn_row_speed, spawn_spawner_speed,
		spawn_stack_count, spawn_stack_speed
	)


func fire_round_gravity(
		rows:Array[RowData_Column], 
		fire_count:int, fire_duration:float, 
		bullet_speed:float, bullet_speed_range:float=0,
		bullet_rotation:float=0, bullet_rotation_speed:float=0,
		bullet_gravity:float=0,
	) -> void:
	
	fire_round(
		rows, 
		fire_count, fire_duration,
		bullet_speed, bullet_speed_range,
		bullet_rotation, bullet_rotation_speed,
		bullet_gravity,
	)


func fire_round_curve(
		rows:Array[RowData_Column], 
		fire_count:int, fire_duration:float, 
		bullet_speed_curve:Curve
	) -> void:
	
	if disabled:
		return
	else:
		shooting = true
	
	%FireTimer.wait_time = snappedf(fire_duration / fire_count, 0.0167)
	%FireTimer.start()
	
	for i in fire_count:
		var row:RowData = rows[i % rows.size()]
		var bullet_speed = bullet_speed_curve.sample(float(i) / fire_count)
		
		fire_row(
			row,
			bullet_speed
		)
		
		await %FireTimer.timeout
	
	shooting = false
	%FireTimer.stop()
	
	await get_tree().process_frame
	finished_round.emit()


func fire_round(
		rows:Array[RowData_Column], 
		fire_count:int, fire_duration:float, 
		bullet_speed:float, bullet_speed_range:float=0,
		bullet_rotation:float=0, bullet_rotation_speed:float=0,
		bullet_gravity:float=0,
		spawn_row_speed:float=0, spawn_spawner_speed:float=0,
		spawn_stack_count:int=1, spawn_stack_speed:float=0
	) -> void:
	
	if disabled:
		return
	else:
		shooting = true
	
	if fire_count == 0 or spawner_count == 0:
		await self.create_tween().tween_interval(fire_duration).finished
		finished_round.emit()
		return
	
	var row_stack = false if (fire_duration != 0) else true
	if !row_stack:
		%FireTimer.wait_time = snappedf(fire_duration / fire_count, 0.0167)
		%FireTimer.start()
	
	# print("New Round")
	# last_time = Time.get_ticks_msec()
	# last_rot = rotation
	# frame_counter = 0
	
	for i in fire_count:
		var row:RowData_Column = rows[i % rows.size()]
		var bullet_adjusted_speed = bullet_speed + (spawn_row_speed * i)
		
		if rotation_random:
			rotation = RNG.randf_range(
				rotation_random_range.x,
				rotation_random_range.y
			)
		
		fire_row(
			row,
			bullet_adjusted_speed, bullet_speed_range,
			bullet_rotation, bullet_rotation_speed,
			bullet_gravity,
			spawn_spawner_speed,
			spawn_stack_count, spawn_stack_speed
		)
		
		if !row_stack:
			await %FireTimer.timeout
	
	shooting = false
	%FireTimer.stop()
	
	await get_tree().process_frame
	finished_round.emit()


func fire_row(
		row:RowData_Column,
		bullet_speed:float, bullet_speed_range:float=0,
		bullet_rotation:float=0, bullet_rotation_speed:float=0,
		bullet_gravity:float=0,
		spawn_spawner_speed:float=0,
		spawn_stack_count:int=1, spawn_stack_speed:float=0
	) -> void:
	
	# print("/// Fire ///")
	# 
	# print("Rotation:", rad_to_deg(rotation - last_rot))
	# last_rot = rotation
	# 
	# print("Time:", Time.get_ticks_msec() - last_time)
	# last_time = Time.get_ticks_msec()
	# 
	# print("Frames:", frame_counter)
	# frame_counter = 0
	
	if GlobalStage.is_current_stage_clear():
		return
	
	if !mute:
		%FireSound.play()
	for i in column_count:
		var column:ColumnData_Bullet = row.get_column(i)
		
		for j in spawner_count:
			var spawner:Pointer = spawner_map[i][j]
			var bullet:BulletData = column.get_bullet(j)
		
			var bullet_adjusted_speed = bullet_speed + (spawn_spawner_speed * j)
			if bullet_speed_range != 0:
				bullet_adjusted_speed = RNG.randf_range(
					bullet_adjusted_speed - bullet_speed_range, 
					bullet_adjusted_speed + bullet_speed_range
				)
			
			for k in spawn_stack_count:
				GlobalPool.bullet_gravity_spawned.emit(
					bullet, spawner.global_transform,
					bullet_adjusted_speed + (spawn_stack_speed * k), 
					deg_to_rad(bullet_rotation), 
					deg_to_rad(bullet_rotation_speed),
					bullet_gravity,
					flash_scale, flash_time, immunity_time
				)


func disable() -> void:
	disabled = true
	%FireTimer.stop()
	
	await get_tree().process_frame
	deactivated.emit()


func disable_wait() -> void:
	disabled = true
	if shooting:
		await self.finished_round
	
	await get_tree().process_frame
	deactivated.emit()


func disable_free() -> void:
	disable()
	queue_free()


func play_sound():
	%FireSound.play()


func _on_FireTimer_timeout() -> void:
	return
