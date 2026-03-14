extends Background

const SPEED := 250.0

var ModulateTween:Tween




func _process(delta):
	%Parallax.scroll_offset.y += SPEED * delta




func hide_background() -> void:
	tween_modulate(0)


func show_background() -> void:
	tween_modulate(1)


func fade_in(time:float=1.0) -> void:
	tween_modulate(1, time)


func fade_out(time:float=2.0) -> void:
	tween_modulate(0, time)




func tween_modulate(alpha:float, time:float=0.0) -> void:
	set_tween()
	for child in %Parallax.get_children():
		ModulateTween.tween_property(child, "modulate:a", alpha, time)


func set_tween() -> void:
	if ModulateTween:
		ModulateTween.kill()
	ModulateTween = self.create_tween().set_parallel(true)
