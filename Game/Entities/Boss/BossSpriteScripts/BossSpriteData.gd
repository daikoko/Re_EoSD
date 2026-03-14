extends Resource
class_name BossSpriteData

const DEFAULT_SPRITE_BASE := preload("res://Game/Entities/Boss/BossSpriteScripts/CustomSprite_Boss.tscn")

@export var sprite_frames:SpriteFrames
@export var sprite_base:PackedScene
@export var sprite_offset:Vector2
@export var hitbox:Shape2D




func get_sprite() -> CustomSprite:
	var sprite = null
	if sprite_base != null:
		sprite = sprite_base.instantiate()
	else:
		sprite = DEFAULT_SPRITE_BASE.instantiate()
	
	sprite.set_sprite(sprite_frames, sprite_offset)
	
	return sprite


func get_hitbox() -> Shape2D:
	return hitbox
