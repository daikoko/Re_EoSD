extends Node2D

var id:int

var Grid:Node2D
var RNG:RandomNumberGenerator
var first_ring:Array = []
var second_ring:Array = []

const ANGLES := [0, 60, 120, 180, 240, 300]
const SPEED := 40.0

const HELPER_17 := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper17.tscn")

signal exiting




func _ready():
	%Follow.modulate.a = 0.0
	%BulletDull.collision_disable()


func _process(delta: float) -> void:
	%Follow.progress += SPEED * delta
	
	%Small.rotation += deg_to_rad(45) * delta
	%Large.rotation -= deg_to_rad(45) * delta


func _exit_tree() -> void:
	exiting.emit()




func set_first_ring():
	for angle in ANGLES:
		var other_tile = Grid.get_tile(
			self.position + (Vector2.RIGHT.rotated(deg_to_rad(angle)) * 100)
		)
		
		if other_tile != null:
			first_ring.append(other_tile)


func get_first_ring() -> Array:
	return first_ring


func set_second_ring():
	for tile in first_ring:
		var candidates = tile.get_first_ring()
		
		for candidate in candidates:
			var repeat = false
			
			if candidate.position == self.position:
				repeat = true
			
			for other_tile in first_ring:
				if candidate.position == other_tile.position:
					repeat = true
			
			for other_tile in second_ring:
				if candidate.position == other_tile.position:
					repeat = true
			
			if not repeat:
				second_ring.append(candidate)


func start_tile():
	%BulletDull.flash(1)
	await get_tree().process_frame
	
	%Follow.progress_ratio = RNG.randf_range(0, 1)
	%Follow.modulate.a = 1.0
	
	%BulletDull.flash(0, 1.2)
	%BulletDull.collision_enable()


func start_small():
	%Small.show()
	
	%Small.scale = Vector2.ONE * 4
	%Small.modulate.a = 0
	
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.        tween_property(%Small, "scale",      Vector2.ONE,     0.4)
	SelfTween.        tween_property(%Small, "modulate:a", 1,               0.4)
	SelfTween.chain().tween_interval(                                       1.6)
	await SelfTween.finished
	
	%Sound.play()
	self.light(0)
	light_first_ring(0.1)
	
	SelfTween = self.create_tween().set_parallel(true)
	SelfTween.chain().tween_property(%Small, "scale",      Vector2.ONE * 4, 0.4)
	SelfTween.        tween_property(%Small, "modulate:a", 0,               0.4)
	await SelfTween.finished
	
	%Small.hide()


func start_large():
	%Large.show()
	
	%Large.scale = Vector2.ONE * 4
	%Large.modulate.a = 0
	
	var SelfTween = self.create_tween().set_parallel(true)
	SelfTween.        tween_property(%Large, "scale",      Vector2.ONE,     0.4)
	SelfTween.        tween_property(%Large, "modulate:a", 1,               0.4)
	SelfTween.chain().tween_interval(                                       1.6)
	await SelfTween.finished
	
	%Sound.play()
	self.light(0)
	light_first_ring(0.1)
	light_second_ring(0.2)
	
	SelfTween = self.create_tween().set_parallel(true)
	SelfTween.chain().tween_property(%Large, "scale",      Vector2.ONE * 4, 0.4)
	SelfTween.        tween_property(%Large, "modulate:a", 0,               0.4)
	await SelfTween.finished
	
	%Large.hide()


func light(delay:float):
	var lighter = HELPER_17.instantiate()
	lighter.position = self.position
	lighter.delay = delay
	exiting.connect(lighter._on_Tile_exiting)
	
	GlobalStage.request_add_object.emit(lighter)


func light_first_ring(delay:float):
	for tile in first_ring:
		tile.light(delay)


func light_second_ring(delay:float):
	for tile in second_ring:
		tile.light(delay)




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
