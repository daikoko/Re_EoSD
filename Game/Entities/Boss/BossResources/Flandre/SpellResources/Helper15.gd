extends Node2D

var tiles:Array = []
var RNG:RandomNumberGenerator

const HELPER_16 := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper16.tscn")




func _ready():
	%Sprite.material.set_shader_parameter("invert",   false)
	%Sprite.material.set_shader_parameter("modifier", 0.0)
	
	var start_position = Vector2(-10, 0)
	var current_id:int = 0
	var alternator = 1
	
	while start_position.y <= 780:
		var current_position = start_position
		
		while current_position.x <= 700:
			var tile = HELPER_16.instantiate()
			tile.position = current_position
			tile.id = current_id
			tile.Grid = self
			tile.RNG = RNG
			tiles.append(tile)
			self.add_child(tile)
			
			current_id += 1
			current_position.x += 100
		
		if alternator == 1:
			start_position += Vector2.RIGHT.rotated(deg_to_rad(60)) * 100
		else:
			start_position += Vector2.RIGHT.rotated(deg_to_rad(120)) * 100
		
		alternator += -1
	
	for tile in tiles:
		tile.set_first_ring()
	
	for tile in tiles:
		tile.set_second_ring()




func start():
	var SelfTween = self.create_tween()
	SelfTween.tween_property(%Sprite, "material:shader_parameter/modifier", 1000.0, 80.0)


func start_tiles():
	for tile in tiles:
		tile.start_tile()


func start_attack_small(count_min:int, count_max:int):
	var count = RNG.randi_range(count_min, count_max)
	var previous = []
	for i in count:
		var tile:int
		var repeat = true
		
		while repeat:
			repeat = false
			tile = RNG.randi_range(0, (tiles.size() - 1))
			for prev_tile in previous:
				if tile == prev_tile:
					repeat = true
					break
		
		previous.append(tile)
	
	for id in previous:
		tiles[id].start_small()


func start_attack_large(count_min:int, count_max:int):
	var count = RNG.randi_range(count_min, count_max)
	var previous = []
	for i in count:
		var tile:int
		var repeat = true
		
		while repeat:
			repeat = false
			tile = RNG.randi_range(0, (tiles.size() - 1))
			for prev_tile in previous:
				if tile == prev_tile:
					repeat = true
					break
		
		previous.append(tile)
	
	for id in previous.size():
		if id < (previous.size() - 2):
			tiles[previous[id]].start_small()
		else:
			tiles[previous[id]].start_large()


func disable():
	%Sprite.material.set_shader_parameter("invert",   true)
	%Sprite.material.set_shader_parameter("modifier", 2)
	
	var SelfTween = self.create_tween()
	SelfTween.tween_property(%Sprite, "material:shader_parameter/modifier", 0.0, 0.4)
	await SelfTween.finished
	
	queue_free()


func get_tile(tile_position) -> Node2D:
	for tile in tiles:
		var tile_rounded = Vector2(
			ceili(tile.position.x),
			ceili(tile.position.y)
		)
		var other_tile_rounded = Vector2(
			ceili(tile_position.x),
			ceili(tile_position.y)
		)
		if tile_rounded == other_tile_rounded:
			return tile
	
	return null
