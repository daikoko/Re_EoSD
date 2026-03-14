extends Shooter
class_name Shooter_Laser

var spawner_map:Array = []
var column_count:int
var spawner_count:int
var free_lasers:int = 0

var rotation_speed:float = 0

var mute:bool = false

signal internal_finished_round




func _process(delta):
	rotation += rotation_speed * delta




func fire_round(
		lasers:RowData_Column,
		laser_duration:float, 
		laser_delay_time:float=1.0, 
		laser_grow_time:float=0.4, 
		laser_shrink_time:float=0.2
	) -> void:
	
	if disabled:
		return
	
	shooting = true
	free_lasers = 0
	
	%DelayTimer.wait_time = laser_delay_time
	%DelayTimer.start()
	for j in column_count:
		var column:ColumnData_Laser = lasers.get_column(j)
		for k in spawner_count:
			var laser_object:Laser = spawner_map[j][k]
			var laser:LaserData = column.get_laser(k)
			
			laser_object.activate(
				laser.color, laser.weight,
				laser_duration, 
				laser_delay_time, 
				laser_grow_time, 
				laser_shrink_time
			)


func disable() -> void:
	for column in spawner_map:
		for laser in column:
			laser.immediate_stop()
	
	disabled = true
	if shooting:
		# print("Waiting")
		await self.internal_finished_round
		# print("Waiting Done")
	
	await get_tree().process_frame
	deactivated.emit()
	
	# print("Full Disable")


func disable_wait() -> void:
	disabled = true
	if shooting:
		await self.internal_finished_round
	
	deactivated.emit()


func disable_free() -> void:
	disable()
	
	await self.deactivated
	queue_free()


func play_sound():
	%FireSound.play()




func _on_Laser_laser_deactivated() -> void:
	free_lasers += 1
	# print("Disable Lasers")
	
	if free_lasers == (column_count * spawner_count):
		shooting = false
		
		await get_tree().process_frame
		internal_finished_round.emit()
		if !disabled:
			finished_round.emit()


func _on_DelayTimer_timeout() -> void:
	if !mute and spawner_count != 0:
		%FireSound.play()
