extends Shooter
class_name Shooter_Arrow

var RNG:RandomNumberGenerator = null

var primary_map:Array = []
var primary_columns:int
var primary_spawners:int

var secondary_object:Node2D

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




func fire_round(
		rows:Array[RowData_Column], 
		fire_count:int, fire_duration:float,
		bullet_speed:float, speed_range:float=0,
		speed_row:float=0, speed_spawner:float=0
	) -> void:
	
	if disabled:
		return
	else:
		shooting = true
	
	var stack = false if (fire_duration != 0) else true
	if !stack:
		%FireTimer.wait_time = snappedf(fire_duration / fire_count, 0.0167)
		%FireTimer.start()
	
	for i in fire_count:
		var row:RowData_Column = rows[i % rows.size()]
		var adjusted_speed = bullet_speed + (speed_row * i)
		
		if rotation_random:
			rotation = RNG.randf_range(
				rotation_random_range.x,
				rotation_random_range.y
			)
		
		fire_row(
			row, 
			adjusted_speed,
			speed_spawner, speed_range
		)
		
		if !stack:
			await %FireTimer.timeout
	
	shooting = false
	%FireTimer.stop()
	
	await get_tree().process_frame
	finished_round.emit()


func fire_row(
		row:RowData_Column, 
		bullet_speed:float, bullet_speed_range:float=0,
		spawn_spawner_speed:float=0
	) -> void:
	
	if GlobalStage.is_current_stage_clear():
		return
	
	if !mute:
		%FireSound.play()
	for i in primary_columns:
		var column:ColumnData_Bullet = row.get_column(i)
		
		for j in primary_spawners:
			var bullet:BulletData = column.get_bullet(j)
			var primary_spawner:Pointer = primary_map[i][j]
			secondary_object.transform = primary_spawner.transform
			
			var bullet_adjusted_speed = bullet_speed + (spawn_spawner_speed * j)
			if bullet_speed_range != 0:
				bullet_adjusted_speed = RNG.randf_range(
					bullet_adjusted_speed - bullet_speed_range, 
					bullet_adjusted_speed + bullet_speed_range
				)
			
			for spawner in secondary_object.get_children():
				GlobalPool.bullet_gravity_spawned.emit(
					bullet, spawner.global_transform,
					bullet_adjusted_speed * spawner.ratio,
					-spawner.rotation, 
					0,
					0,
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
