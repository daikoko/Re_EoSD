extends Resource
class_name EnemySpriteData

const SPRITE := preload("res://Game/Objects/Sprites/CustomSprite.tscn")

@export var sprite_frames:SpriteFrames
@export var sprite_base:PackedScene
@export var sprite_offset:Vector2
@export var hitbox:Shape2D




func get_sprite() -> CustomSprite:
	var sprite = null
	if sprite_base == null:
		sprite = SPRITE.instantiate()
	else:
		sprite = sprite_base.instantiate()
	sprite.sprite_frames = sprite_frames
	sprite.offset = sprite_offset
	
	return sprite


func get_hitbox() -> Shape2D:
	return hitbox
