extends Node2D

var DarkTween:Tween
var disabled:bool


func _ready():
	%Darkness.scale = Vector2.ZERO
	%Darkness.modulate.a = 1
	%DarknessPlayer.modulate.a = 0
	GlobalPlayer.player_used_bomb.connect(_on_GlobalStage_player_used_bomb)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalStage_player_used_bomb_stop)


func _process(_delta:float) -> void:
	%DarknessPlayer.global_position = GlobalPlayer.get_player_position()




func start():
	DarkTween = set_tween()
	DarkTween.tween_property(%Darkness, "scale",      Vector2.ONE * 20, 1.4)
	DarkTween.tween_interval(                                           0.2)
	await DarkTween.finished
	
	%DarknessPlayer.modulate.a = 1.0
	DarkTween = set_tween()
	DarkTween.tween_property(%Darkness, "modulate:a", 0, 1.0)


func disable():
	disabled = true
	var DarkTween = self.create_tween()
	DarkTween.tween_property(%DarknessPlayer, "modulate:a", 0, 0.8)




func set_tween() -> Tween:
	if DarkTween:
		DarkTween.kill()
	
	return self.create_tween().set_parallel(true)




func _on_GlobalStage_player_used_bomb(_spellname):
	if disabled: return
	
	DarkTween = set_tween()
	DarkTween.tween_property(%DarknessPlayer, "modulate:a", 0, 0.2)


func _on_GlobalStage_player_used_bomb_stop():
	if disabled: return
	
	DarkTween = set_tween()
	DarkTween.tween_property(%DarknessPlayer, "modulate:a", 1.0, 0.4)
