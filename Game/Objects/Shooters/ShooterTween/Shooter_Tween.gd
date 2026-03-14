extends Shooter
class_name Shooter_Tween

var RNG:RandomNumberGenerator = null

var spawner_map:Array = []
var spawner_count:int

var rotation_speed:float = 0
var rotation_random:bool = false

var shooter_reversed:bool
var bullet_direct:bool

var flash_scale:float = 2.0
var flash_time:float = 0.2
var immunity_time:float = 0.1
var mute:bool = false

signal finished_row




func _process(delta):
	rotation += rotation_speed * delta


func fire_round_full(
		rows:Array[RowData_Bullet], 
		fire_count:int, fire_duration:float,
		bullet_rotation:float, bullet_rotation_speed:float,
		tween_time:float, tween_max_rotation:float, tween_min_rotation:float, 
		tween_double:bool=false, tween_double_rows:Array[RowData_Bullet]=[],
		tween_flip_interval:int=1000
	) -> void:
	
	var tween_distance = GlobalShooter.make_curve(
		Vector2(0,GlobalStage.MAX_DIAGONAL), 
			[
				Vector2.ZERO,
				Vector2(1, GlobalStage.MAX_DIAGONAL)
			]
		)
	var tween_rotation = GlobalShooter.make_curve(
		Vector2(tween_min_rotation, tween_max_rotation), 
			[
				Vector2(0, tween_max_rotation),
				Vector2(1, tween_min_rotation)
			]
		)
	
	fire_round(
		rows, 
		fire_count, fire_duration,
		bullet_rotation, bullet_rotation_speed,
		tween_time, tween_distance, tween_rotation, 
		0, 
		0, false,
		tween_double, tween_double_rows,
		tween_flip_interval
	)


func fire_round(
		rows:Array[RowData_Bullet], 
		fire_count:int, fire_duration:float,
		bullet_rotation:float, bullet_rotation_speed:float,
		tween_time:float, tween_distance:Curve, tween_rotation:Curve, 
		tween_release_speed:float=0, 
		tween_release_angle:float=0, tween_release_aim:bool=false,
		tween_double:bool=false, tween_double_rows:Array[RowData_Bullet]=[],
		tween_flip_interval:int=1000
	) -> void:
	
	if disabled:
		return
	else:
		shooting = true
	
	if tween_double_rows == []:
		tween_double_rows = rows
	
	var row_stack = false if (fire_duration != 0) else true
	if !row_stack:
		%FireTimer.wait_time = snappedf(fire_duration / fire_count, 0.0167)
		%FireTimer.start()
	
	for i in fire_count:
		var row:RowData_Bullet = rows[i % rows.size()]
		var double_row:RowData_Bullet = tween_double_rows[i % tween_double_rows.size()]
		var reversed = (i / tween_flip_interval) % 2 == 1
		if shooter_reversed: reversed = not reversed
		
		if rotation_random:
			rotation = RNG.randf_range(0, TAU)
		
		fire_row(
			row,
			bullet_rotation, bullet_rotation_speed,
			tween_time, tween_distance, tween_rotation,
			tween_release_speed, 
			tween_release_angle, tween_release_aim, 
			tween_double, double_row,
			reversed
		)
		
		if !row_stack:
			await %FireTimer.timeout
	
	shooting = false
	$FireTimer.stop()
	
	await get_tree().process_frame
	finished_round.emit()


func fire_row(
		row:RowData,
		bullet_rotation:float, bullet_rotation_speed:float,
		tween_time:float, tween_distance:Curve, tween_rotation:Curve,
		tween_release_speed:float, 
		tween_release_angle:float, tween_release_aim:bool,
		tween_double:bool, tween_double_row:RowData,
		tween_reverse:bool
	) -> void:
	
	if GlobalStage.is_current_stage_clear():
		return
	
	if tween_double_row == null:
		tween_double_row = row
	
	if !mute:
		%FireSound.play()
	for i in spawner_count:
		var spawner:Pointer = spawner_map[i]
		var bullet:BulletData = row.get_bullet(i)
		var double_bullet:BulletData = tween_double_row.get_bullet(i)
		
		GlobalPool.bullet_tween_spawned.emit(
			bullet, spawner.global_transform,
			self.global_position, spawner.distance, spawner.ratio, spawner.global_rotation, 
			tween_time, tween_distance, tween_rotation, check_reverse(tween_reverse),
			bullet_direct, deg_to_rad(bullet_rotation), deg_to_rad(bullet_rotation_speed),
			tween_release_speed, 
			deg_to_rad(tween_release_angle), tween_release_aim,
			flash_scale, flash_time, immunity_time
		)
		
		if tween_double:
			GlobalPool.bullet_tween_spawned.emit(
				double_bullet, spawner.global_transform,
				self.global_position, spawner.distance, spawner.ratio, spawner.global_rotation, 
				tween_time, tween_distance, tween_rotation, check_reverse(!tween_reverse),
				bullet_direct, -deg_to_rad(bullet_rotation), -deg_to_rad(bullet_rotation_speed),
				tween_release_speed, 
				deg_to_rad(tween_release_angle), tween_release_aim,
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


func check_reverse(flipped) -> int:
	if flipped:
		return -1
	else:
		return 1


func play_sound():
	%FireSound.play()
