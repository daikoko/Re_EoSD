extends Node2D

var origin:Vector2
var direction:Vector2
var distance:float
var time:float

var distance_current:float
var rotation_speed:float
var reversed:int

var fire_count:int
var linear_delay:float
var linear_time:float
var linear_speed:float

var mute:bool




func _ready() -> void:
	%ShadowHandler.effect_start()
	fire()
	
	await create_tween().tween_property(self, "distance_current", distance, time).finished
	queue_free()


func _process(delta:float) -> void:
	self.position = origin + (direction.rotated(rotation) * distance_current)
	self.rotation += rotation_speed * delta * reversed




func build(
		origin:Vector2, 
		direction:Vector2, 
		distance:float, 
		time:float, 
		rotation_speed:float, 
		reversed:int,
		fire_count:int, 
		linear_delay:float,
		linear_time:float,
		linear_speed:float,
	) -> void:
	
	self.origin = origin
	self.direction = direction
	self.distance = distance
	self.time = time
	
	self.rotation_speed = rotation_speed
	self.reversed = reversed
	
	self.fire_count = fire_count
	self.linear_delay = linear_delay
	self.linear_time = linear_time
	self.linear_speed = linear_speed


func fire():
	await self.create_tween().tween_interval(0.2).finished
	
	var angle_step = (TAU / fire_count) * reversed
	
	%Timer.wait_time = (time / fire_count)
	%Timer.start()
	
	for _i in fire_count:
		if !mute: %Sound.play()
		
		GlobalPool.bullet_linear_spawned.emit(
			GlobalShooter.BRIGHT_RED, %Guide.global_transform,
			0, 0, 0, 0,
			linear_delay, linear_time, linear_speed, 0,
			2.0, 0.2, 4.0
		)
		
		await %Timer.timeout
		
		%Guide.rotate(angle_step)




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
