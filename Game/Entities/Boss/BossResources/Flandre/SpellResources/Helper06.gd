extends Node2D

var RNG:RandomNumberGenerator
var mute:bool

const TIME_DELAY := 0.2




func _ready():
	%Blinker.hide()




func start(
		time_wait:float,
		time_blink:float,
		fire_count:int,
		bullet_speed:float,
		bullet_speed_range:float
	):
	
	await self.create_tween().tween_interval(time_wait).finished
	
	%Timer.start()
	await self.create_tween().tween_interval(time_blink).finished
	
	%Timer.stop()
	%Blinker.show()
	
	await self.create_tween().tween_interval(TIME_DELAY).finished
	%Blinker.hide()
	fire(
		fire_count,
		bullet_speed,
		bullet_speed_range
	)
	
	await self.create_tween().tween_interval(0.8).finished
	queue_free()




func fire(
		fire_count:int,
		bullet_speed:float,
		bullet_speed_range:float
	):
	
	var spawner = Marker2D.new()
	self.add_child(spawner)
	for _i in fire_count:
		var spawner_rotation = RNG.randf_range(0, TAU / 12)
		var bullet_speed_random = RNG.randf_range(
			bullet_speed - bullet_speed_range,
			bullet_speed + bullet_speed_range
		)
		
		spawner.position = Vector2.UP.rotated(spawner_rotation) * 120
		spawner.rotation = (- TAU / 4) + spawner_rotation
		GlobalPool.bullet_gravity_spawned.emit(
			GlobalShooter.BRIGHT_RED, spawner.global_transform,
			bullet_speed_random
		)
	
	if not mute: %Sound.play()




func _on_Timer_timeout() -> void:
	if not %Blinker.visible:
		%Blinker.show()
	else:
		%Blinker.hide()
