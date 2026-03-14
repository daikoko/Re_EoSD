extends PathFollow2D

enum STATUS {
	ENTERING,
	STOPPED,
	EXITING,
	WAITING,
	DEATH
}

var status:int

var sprite:CustomSprite
var hitbox:Shape2D
var health:int
var speed:float
var exit_speed:float

var shooters:Array[EnemyShooter]
var death_shooters:Array[EnemyShooter]
var death:DeathData

var active_shooters:int = 0
var active_death_shooters:int = 0

var retreat:bool
var retreat_time:float

signal all_shooters_deactivated
signal all_death_shooters_deactivated




func _ready():
	add_child(sprite)
	%Enemy.set_shape(hitbox)
	
	status = STATUS.ENTERING
	if !retreat:
		start_shooter()


func _process(delta):
	match status:
		STATUS.ENTERING:
			progress += speed * delta
			check_distance()
	
		STATUS.STOPPED:
			pass
	
		STATUS.EXITING:
			progress -= exit_speed * delta
	
		STATUS.WAITING:
			if active_shooters == 0:
				await get_tree().process_frame
				all_shooters_deactivated.emit()
	
		STATUS.DEATH:
			if active_death_shooters == 0:
				await get_tree().process_frame
				all_death_shooters_deactivated.emit()




func check_distance() -> void:
	if progress_ratio == 1:
		if retreat:
			enemy_wait_to_retreat()
		else:
			enemy_exit()


func enemy_wait_to_retreat():
	status = STATUS.STOPPED
	start_shooter()
	
	var RetreatTimer = GlobalStage.create_timer(self, retreat_time)
	RetreatTimer.start()
	await RetreatTimer.timeout
	
	enemy_retreat()


func enemy_retreat():
	status = STATUS.WAITING
	stop_shooter()
	await self.all_shooters_deactivated
	
	status = STATUS.EXITING


func enemy_exit():
	status = STATUS.WAITING
	if active_shooters > 0:
		stop_shooter_immediate()
		await self.all_shooters_deactivated
	
	queue_free()


func start_shooter() -> void:
	for shooter in shooters:
		shooter.start()


func start_death_shooter() -> void:
	for shooter in death_shooters:
		shooter.death_start()


func stop_shooter() -> void:
	for shooter in shooters:
		shooter.stop()


func stop_shooter_immediate() -> void:
	for shooter in shooters:
		shooter.stop_immediate()




func enemy_death():
	status = STATUS.DEATH
	sprite.visible = false
	%Enemy.disable()
	%Sound_Death.play()
	
	stop_shooter_immediate()
	start_death_shooter()
	death.start(global_position)
	await all_death_shooters_deactivated
	
	var DeathTimer = GlobalStage.create_timer(self)
	DeathTimer.start()
	await DeathTimer.timeout
	
	queue_free()




func _on_Enemy_collider_hit(damage:int):
	if health <= 0:
		return

	# print("Damage Taken: ", damage)
	health -= damage
	sprite.flash()

	if health <= 0:
		enemy_death()
	else:
		%Sound_Hit.play()


func _on_Enemy_collider_entered(_other, other_identity):
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()


func _on_Visibility_screen_exited():
	enemy_exit()


func _on_Shooter_deactivated():
	active_shooters -= 1


func _on_DeathShooter_deactivated():
	active_death_shooters -= 1
