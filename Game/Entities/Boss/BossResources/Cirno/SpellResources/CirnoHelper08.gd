extends Node2D

var RNG:RandomNumberGenerator
var follower_identity = ""




func set_identity(identity:String):
	self.follower_identity = identity


func relocate():
	self.global_position = Vector2(
		RNG.randf_range(200, GlobalStage.VIEWPORT_SIZE.x - 200),
		RNG.randf_range(250, GlobalStage.VIEWPORT_SIZE.y - 250)
	)
	
	%Collider.disable()
	await get_tree().process_frame
	
	%Collider.enable()




func _on_Collider_collider_entered(_other, other_identity):
	if other_identity == follower_identity:
		relocate()
