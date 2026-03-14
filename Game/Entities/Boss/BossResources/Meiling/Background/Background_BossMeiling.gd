extends Background

const HELPER_01 := preload("res://Game/Entities/Boss/BossResources/Meiling/Background/Helper01.tscn")

const SMALL_SPRITE := preload("res://Game/Entities/Boss/BossResources/Meiling/Background/Background_BossMeiling02.png")
const SMALL_SPRITE_SPEED := 160.0
const SMALL_SPRITE_ROTATION_SPEED := -30.0

const LARGE_SPRITE := preload("res://Game/Entities/Boss/BossResources/Meiling/Background/Background_BossMeiling03.png")
const LARGE_SPRITE_SPEED := 80.0
const LARGE_SPRITE_ROTATION_SPEED := 30.0

var RNG:RandomNumberGenerator
var ModulateTween:Tween




func _ready():
	RNG = RandomNumberGenerator.new()
	RNG.seed = 19249717




func hide_background() -> void:
	tween_modulate(0)


func show_background() -> void:
	tween_modulate(1)


func fade_in(time:float=1.0) -> void:
	tween_modulate(1, time)


func fade_out(time:float=1.6) -> void:
	tween_modulate(0, time)




func tween_modulate(alpha:float, time:float=0.0) -> void:
	set_tween()
	ModulateTween.tween_property(%TextureRect, "modulate:a", alpha, time)


func set_tween() -> void:
	if ModulateTween:
		ModulateTween.kill()
	ModulateTween = GlobalStage.create_tween().set_parallel(true)




func _on_SmallSpawnTimer_timeout() -> void:
	var sprite =            HELPER_01.instantiate()
	sprite.texture =        SMALL_SPRITE
	sprite.speed =          SMALL_SPRITE_SPEED
	sprite.rotation_speed = SMALL_SPRITE_ROTATION_SPEED
	
	sprite.position = Vector2(
		RNG.randf_range(20, 660),
		-120
	)
	sprite.rotation = (
		RNG.randf_range(0, TAU)
	)
	
	%TextureRect.add_child(sprite)


func _on_LargeSpawnTimer_timeout() -> void:
	var sprite =            HELPER_01.instantiate()
	sprite.texture =        LARGE_SPRITE
	sprite.speed =          LARGE_SPRITE_SPEED
	sprite.rotation_speed = LARGE_SPRITE_ROTATION_SPEED
	
	sprite.position = Vector2(
		RNG.randf_range(20, 660),
		-120
	)
	sprite.rotation = (
		RNG.randf_range(0, TAU)
	)
	
	%TextureRect.add_child(sprite)
