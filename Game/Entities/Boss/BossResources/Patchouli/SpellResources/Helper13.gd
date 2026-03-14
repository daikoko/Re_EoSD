extends Node2D

const HELPER_14 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper14.tscn")
const HELPER_15 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper15.tscn")
const HELPER_16 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper16.tscn")

var RNG:RandomNumberGenerator
var disabled:bool = false




func fire_orange(amount:int):
	if disabled:
		return
	
	for i in amount:
		var shot = HELPER_14.instantiate()
		var angle = TAU * (float(i) / amount)
		
		shot.RNG = RNG
		shot.rotation = angle
		shot.mute = (i != 0)
		self.add_child(shot)


func fire_yellow(amount:int):
	if disabled:
		return
	
	for i in amount:
		var shot = HELPER_15.instantiate()
		var angle = TAU * (float(i) / amount)
		
		shot.RNG = RNG
		shot.rotation = angle
		shot.mute = (i != 0)
		self.add_child(shot)


func fire_red(amount:int):
	if disabled:
		return
	
	for i in amount:
		var shot = HELPER_16.instantiate()
		var angle = TAU * (float(i) / amount)
		
		shot.RNG = RNG
		shot.rotation = angle
		shot.mute = (i != 0)
		self.add_child(shot)




func disable():
	disabled = true
	
	for child in self.get_children():
		child.queue_free()
