extends Shooter
class_name Shooter_Sine

var spawner_map:Array = []
var column_count:int
var spawner_count:int

var RNG:RandomNumberGenerator
var rotation_speed:float = 0

var flash_scale:float = 2.0
var flash_time:float = 0.2
var immunity_time:float = 0.1
var mute:bool = false

signal finished_row




func _process(delta):
	rotation += rotation_speed * delta




func fire_round(
		rows:Array[RowData_Column], 
		fire_count:int, fire_duration:float,
		bullet_speed:float, 
		sine_amplitude:float=40, sine_compression:float=4,
		sine_double:bool=false, sine_double_rows:Array[RowData_Column]=[],
		spawn_spawner_speed:float=0
	) -> void:
	
	if disabled:
		return
	else:
		shooting = true
	
	if sine_double_rows == []:
		sine_double_rows = rows
	
	var row_stack = false if (fire_duration != 0) else true
	if !row_stack:
		%FireTimer.wait_time = snappedf(fire_duration / fire_count, 0.0167)
		%FireTimer.start()
	
	for i in fire_count:
		var row:RowData_Column = rows[i % rows.size()]
		var double_row:RowData_Column = sine_double_rows[i % sine_double_rows.size()]
		
		fire_row(
			row,
			bullet_speed, 
			sine_amplitude, sine_compression, 
			sine_double, double_row,
			spawn_spawner_speed
		)
		
		if !row_stack:
			await %FireTimer.timeout
	
	shooting = false
	%FireTimer.stop()
	
	await get_tree().process_frame
	finished_round.emit()


func fire_row(
		row:RowData_Column,
		bullet_speed:float, 
		sine_amplitude:float=0, sine_compression:float=0, 
		sine_double:bool=false, sine_double_row:RowData_Column=null,
		spawn_spawner_speed:float=0
	) -> void:
	
	if GlobalStage.is_current_stage_clear():
		return
	
	if sine_double_row == null:
		sine_double_row = row
	
	if !mute:
		%FireSound.play()
	for i in column_count:
		var column:ColumnData_Bullet = row.get_column(i)
		var double_column:ColumnData_Bullet = sine_double_row.get_column(i)
		
		for j in spawner_count:
			var spawner:Pointer = spawner_map[i][j]
			var bullet:BulletData = column.get_bullet(j)
			var double_bullet:BulletData = double_column.get_bullet(j)
			var bullet_adjusted_speed = bullet_speed + (spawn_spawner_speed * j)
			
			GlobalPool.bullet_sine_spawned.emit(
				bullet, spawner.global_transform,
				bullet_adjusted_speed, 
				sine_amplitude, sine_compression,
				flash_scale, flash_time, immunity_time
			)
			
			if sine_double:
				GlobalPool.bullet_sine_spawned.emit(
					double_bullet, spawner.global_transform,
					bullet_adjusted_speed, 
					-sine_amplitude, sine_compression,
					flash_scale, flash_time, immunity_time
				)


func disable() -> void:
	%FireTimer.stop()
	
	disabled = true
	deactivated.emit()


func disable_wait() -> void:
	disabled = true
	if shooting:
		await self.finished_round
	
	deactivated.emit()


func disable_free() -> void:
	disable()
	queue_free()


func play_sound():
	%FireSound.play()
