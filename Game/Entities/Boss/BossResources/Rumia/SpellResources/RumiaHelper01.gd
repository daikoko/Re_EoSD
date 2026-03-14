extends Node2D

var active:bool = false
var ModulateTween:Tween



func _ready():
	toggle_active(true)


func _process(_delta):
	if (GlobalStage.is_current_stage_clear() or GlobalStage.is_current_player_bomb()) and active:
		toggle_active(false)
	if !(GlobalStage.is_current_stage_clear() or GlobalStage.is_current_player_bomb()) and !active:
		toggle_active(true)


func toggle_active(toggle:bool):
	if toggle:
		active = true
		%Collider.enable()
		
		set_modulate_tween()
		ModulateTween.tween_property(self, "modulate:a", 0.8, 0.4)
	
	else:
		active = false
		%Collider.disable()
		
		set_modulate_tween()
		ModulateTween.tween_property(self, "modulate:a", 0.4, 0.4)


func set_modulate_tween():
	if ModulateTween:
		ModulateTween.kill()
	
	ModulateTween = create_tween()




func _on_Collider_collider_entered(_other, other_identity):
	if other_identity == "PlayerHitbox":
		GlobalPlayer.player_hit.emit()
