extends Node2D

const HELPER_05 := preload("res://Game/Entities/Boss/BossResources/Meiling/SpellResources/Helper05.tscn")
const HELPER_06 := preload("res://Game/Entities/Boss/BossResources/Meiling/SpellResources/Helper06.tscn")

const TOTAL_LENGTH := 526.34
const TRAIL_LENGTH := 400.0
const SPEED := 3200.0
const COUNT := 50
const COUNT_ARC := 3

var BULLET_COUNT := 4
var DELAY_ADD := 0.2

var followers:Array = []

var head_progress:float = 0
var internal_phase:int = 1

var reversed:bool = false
var RNG:RandomNumberGenerator




func _ready():
	%Head.hide()
	%Head.progress = 0
	set_process(false)


func _process(delta):
	head_progress += delta * SPEED
	if head_progress > TOTAL_LENGTH + (TRAIL_LENGTH * 2):
		set_process(false)
		finish()
	
	if head_progress < TOTAL_LENGTH:
		if reversed == false:
			%Head.progress = head_progress
		else:
			%Head.progress = TOTAL_LENGTH - head_progress
	else:
		%Head.hide()
	
	place_followers()




func reset() -> void:
	self.internal_phase = 1


func start() -> void:
	head_progress = 0
	if reversed == false:
		%Head.progress = 0
	else:
		%Head.progress = TOTAL_LENGTH
	
	%Head.show()
	if followers == []:
		for i in COUNT:
			var follower = HELPER_05.instantiate()
			followers.append(follower)
			%Path.add_child(follower)
	
	set_process(true)
	place_bullets()


func finish() -> void:
	if internal_phase < 3:
		if reversed == false:
			self.rotation += deg_to_rad(120)
		else:
			self.rotation -= deg_to_rad(120)
		
		internal_phase += 1
		start()


func place_followers():
	var actual_trail_length
	if head_progress < TRAIL_LENGTH:
		actual_trail_length = head_progress
	else:
		actual_trail_length = TRAIL_LENGTH
	
	for i in followers.size():
		var follower = followers[i]
		
		var rat = float(i) / COUNT
		var sca = 1 - rat
		var pos = head_progress - (rat * actual_trail_length)
		if pos < TOTAL_LENGTH:
			follower.show()
			follower.scale = Vector2.ONE * sca
			if reversed == false:
				follower.progress = pos
			else:
				follower.progress = TOTAL_LENGTH - pos
		else:
			follower.hide()


func place_bullets():
	%Timer.start()
	for i in BULLET_COUNT:
		if reversed == false:
			%Marker.progress_ratio = (float(i + 1) / BULLET_COUNT)
		else:
			%Marker.progress_ratio = 1 - (float(i + 1) / BULLET_COUNT)
		
		var delay = i * DELAY_ADD
		var major = (i + 1) == BULLET_COUNT
		
		var bullet = HELPER_06.instantiate()
		GlobalStage.request_add_object.emit(bullet)
		
		bullet.global_position = %Marker.global_position
		bullet.set_rotater(RNG, delay, major)
		
		%Sound.play()
		
		await %Timer.timeout
