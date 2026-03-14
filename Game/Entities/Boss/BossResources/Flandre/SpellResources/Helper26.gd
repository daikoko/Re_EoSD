extends Node2D

var RNG:RandomNumberGenerator
var disabled:bool

var ball:Node2D

const HELPER_27 := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper27.tscn")




func prepare(ball:Node2D):
	self.ball = ball


func start_loop(
		brick_fire_time,
		fire_count,
		bullet_speed,
		bullet_speed_range
	):
	
	while not disabled:
		var brick = HELPER_27.instantiate()
		var pos = Vector2.ZERO
		
		var retry = true
		var tries = 120
		while retry and (tries > 0):
			retry = false
			
			pos = Vector2(
				RNG.randf_range(40, 640),
				RNG.randf_range(40, 440)
			)
			
			if (pos - ball.position).length_squared() < 10000:
				retry = true
				continue
			
			for child in self.get_children():
				if (pos - child.position).length_squared() < 4000:
					retry = true
					break
			
			tries -= 1
		
		if tries > 0:
			brick.RNG = RNG
			brick.position = pos
			brick.prepare(
				fire_count,
				bullet_speed,
				bullet_speed_range
			)
			self.add_child(brick)
		
		await self.create_tween().tween_interval(brick_fire_time).finished


func disable():
	disabled = true
	
	for child in self.get_children():
		child.disable()
	
	queue_free()
