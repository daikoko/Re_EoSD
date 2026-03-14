extends Background

const SPEED_01 := Vector2(  0, 160)
const SPEED_02 := Vector2( 40, 240)
const SPEED_03 := Vector2(-40, 240)

var ModulateTween:Tween




func _process(delta):
	%Parallax01.scroll_offset += SPEED_01 * delta
	%Parallax02.scroll_offset += SPEED_02 * delta
	%Parallax03.scroll_offset += SPEED_03 * delta




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
	ModulateTween.tween_property(%Texture01, "modulate:a", alpha, time)
	ModulateTween.tween_property(%Texture02, "modulate:a", alpha, time)
	ModulateTween.tween_property(%Texture03, "modulate:a", alpha, time)
	ModulateTween.tween_property(%Texture04, "modulate:a", alpha, time)


func set_tween() -> void:
	if ModulateTween:
		ModulateTween.kill()
	ModulateTween = GlobalStage.create_tween().set_parallel(true)
