extends Shooter
class_name Shooter_Shape

var RNG:RandomNumberGenerator = null

var spawner_map:Array = []
var spawner_count:int

var rotation_speed:float = 0

var flash_scale:float = 2.0
var flash_time:float = 0.2
var immunity_time:float = 0.1
var mute:bool = false

signal finished_row




func _process(delta):
	rotation += rotation_speed * delta




func fire_round(
		rows:Array[RowData_Bullet], 
		fire_count:int, fire_duration:float,
		bullet_speed:float, bullet_follow_shape:bool=true, 
		bullet_rotation:float=0, bullet_rotation_speed:float=0,
		spawn_row_speed:float=0,
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
		var row:RowData_Bullet = rows[i % rows.size()]
		var bullet_adjusted_speed = bullet_speed + (spawn_row_speed * i)
		
		fire_row(
			row,
			bullet_adjusted_speed, bullet_follow_shape, 
			bullet_rotation, bullet_rotation_speed,
			spawn_stack_count, spawn_stack_speed
		)
		
		if !row_stack:
			await %FireTimer.timeout
	
	shooting = false
	%FireTimer.stop()
	
	await get_tree().process_frame
	finished_round.emit()


func fire_row(
		row:RowData_Bullet,
		bullet_speed:float, bullet_follow_shape:bool=true, 
		bullet_rotation:float=0, bullet_rotation_speed:float=0,
		spawn_stack_count:int=1, spawn_stack_speed:float=0
	) -> void:
	
	if GlobalStage.is_current_stage_clear():
		return
	
	if !mute:
		%FireSound.play()
	for i in spawner_count:
		var spawner:Pointer = spawner_map[i]
		var bullet:BulletData = row.get_bullet(i)
		
		var bullet_speed_modifier:float = spawner.ratio if (bullet_follow_shape) else 1.0
		
		for j in spawn_stack_count:
			var bullet_adjusted_speed = bullet_speed + (spawn_stack_speed * j)
			
			GlobalPool.bullet_gravity_spawned.emit(
				bullet, spawner.global_transform,
				bullet_adjusted_speed * bullet_speed_modifier, 
				deg_to_rad(bullet_rotation), 
				deg_to_rad(bullet_rotation_speed), 
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
