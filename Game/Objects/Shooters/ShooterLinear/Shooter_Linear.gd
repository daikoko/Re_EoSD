extends Shooter
class_name Shooter_Linear

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

signal finished_row




func _process(delta):
	rotation += rotation_speed * delta




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
		0, 0,
		0, 
		0, 
		spawn_row_speed, spawn_spawner_speed, 
		spawn_stack_count, spawn_stack_speed
	)


func fire_round_curve(
		rows:Array[RowData_Column], 
		fire_count:int, fire_duration:float, 
		bullet_speed_curve:Curve,
		linear_delay:float=0, linear_time:float=0, 
		linear_speed_change:float=0, 
		linear_direction_change:float=0
	) -> void:
	
	if disabled:
		return
	
	shooting = true
	%FireTimer.wait_time = snappedf(fire_duration / fire_count, 0.0167)
	%FireTimer.start()
	
	for i in fire_count:
		var row:RowData = rows[i % rows.size()]
		var bullet_speed = bullet_speed_curve.sample(float(i) / fire_count)
		
		fire_row(
			row,
			bullet_speed, 0, 
			0, 0,
			linear_delay, linear_time, 
			linear_speed_change, 
			linear_direction_change,
			0,
			0, 0
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
		linear_delay:float=0, linear_time:float=0, 
		linear_speed_change:float=0, 
		linear_direction_change:float=0,
		spawn_row_speed:float=0, spawn_spawner_speed:float=0,
		spawn_stack_count:int=1, spawn_stack_speed:float=0
	) -> void:
	
	if disabled:
		return
	else:
		shooting = true
	
	var row_stack = false if (fire_duration != 0) else true
	if !row_stack:
		%FireTimer.wait_time = snappedf(fire_duration / fire_count, 0.0167)
		%FireTimer.start()
	
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
			linear_delay, linear_time, 
			linear_speed_change, 
			linear_direction_change,
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
		linear_delay:float=0, linear_time:float=0, 
		linear_speed_change:float=0, 
		linear_direction_change:float=0,
		spawn_spawner_speed:float=0,
		spawn_stack_count:int=1, spawn_stack_speed:float=0
	) -> void:
	
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
				bullet_adjusted_speed += (spawn_stack_speed * k)
				GlobalPool.bullet_linear_spawned.emit(
					bullet, spawner.global_transform,
					bullet_adjusted_speed, 0, 
					deg_to_rad(bullet_rotation), 
					deg_to_rad(bullet_rotation_speed),
					linear_delay, linear_time, 
					linear_speed_change, 
					deg_to_rad(linear_direction_change),
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
