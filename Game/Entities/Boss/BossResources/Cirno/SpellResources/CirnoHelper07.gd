extends Node2D

const HELPER_08 := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper08.tscn")
const HELPER_09 := preload("res://Game/Entities/Boss/BossResources/Cirno/SpellResources/CirnoHelper09.tscn")
const ROT_SPEED := 80.0

var guide_list:Array = []
var follower_list:Array = []

var count:int
var bullet_speed:float
var RNG:RandomNumberGenerator

var stopped:bool = false
var empty:bool




func set_helper(count:int, bullet_speed:float, RNG:RandomNumberGenerator):
	self.count = count
	self.bullet_speed = bullet_speed
	self.RNG = RNG


func start():
	for i in count:
		spawn()


func spawn():
	var guide = HELPER_08.instantiate()
	guide_list.append(guide)
	
	self.add_child(guide)
	guide.RNG = RNG
	guide.relocate()
	
	var follower = HELPER_09.instantiate()
	follower.single_deactivate.connect(_on_Follower_single_deactivate)
	follower_list.append(follower)
	
	self.add_child(follower)
	follower.global_position = self.global_position
	follower.rotation = RNG.randf_range(0, TAU)
	follower.target = guide
	follower.velocity = follower.transform.x * follower.SPEED
	follower.bullet_speed = bullet_speed
	follower.RNG = RNG
	
	var follower_identity = follower.to_string()
	guide.set_identity(follower_identity)
	follower.set_identity(follower_identity)


func disable() -> void:
	queue_free()




func _on_Follower_single_deactivate():
	%DelayTimer.start()
	await %DelayTimer.timeout
	
	spawn()
