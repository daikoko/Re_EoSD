extends Node2D

const SPRITE := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaDarkGlow.png")

var time_delay:float
var time_grow:float
var time_wait:float
var time_end:float

var DarkTween:Tween
var ClearTween:Tween
var linked_sprite:Node2D

var direction:int
var rotation_speed:float

var clear:bool = false




func _ready() -> void:
	%Sprite.scale = Vector2.ZERO
	
	fire()
	rotate_start()


func _process(delta:float) -> void:
	self.rotation += deg_to_rad(rotation_speed) * delta * direction
	linked_sprite.global_transform = %Sprite.global_transform




func fire() -> void:
	DarkTween = create_tween()
	DarkTween.tween_interval(time_delay)
	await DarkTween.finished
	
	%Sound.play()
	
	DarkTween = create_tween()
	DarkTween.tween_property(%Sprite, "scale", Vector2.ONE * 0.4, time_grow)
	DarkTween.tween_interval(time_wait)
	DarkTween.tween_property(%Sprite, "scale", Vector2.ZERO, time_end)
	await DarkTween.finished
	
	end()


func rotate_start() -> void:
	rotation_speed = 120
	
	var RotTween = create_tween()
	RotTween.tween_interval(time_delay - 0.2)
	RotTween.tween_property(self, "rotation_speed", 12, 0.4)


func end():
	if DarkTween:
		DarkTween.kill()
	
	DarkTween = create_tween()
	DarkTween.tween_property(%Sprite, "scale", Vector2.ZERO, 0.2)
	await DarkTween.finished
	
	queue_free()


func get_glow() -> Sprite2D:
	linked_sprite = Sprite2D.new()
	linked_sprite.texture = SPRITE
	linked_sprite.scale = Vector2.ZERO
	
	return linked_sprite




func _on_Collider_collider_entered(_other:Collider, other_identity:String) -> void:
	if (
			other_identity == "PlayerHitbox" and 
			not GlobalStage.is_current_player_bomb() and 
			not GlobalStage.is_current_stage_clear()
		):
		
		GlobalPlayer.player_hit.emit()


func _on_Self_tree_exiting() -> void:
	linked_sprite.queue_free()
