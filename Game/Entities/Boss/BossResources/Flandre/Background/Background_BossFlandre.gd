extends Background

const SPEED := 250.0

var ModulateTween:Tween




func _process(delta):
	%Layer02.rotation += delta * deg_to_rad(10)
	%Layer03.rotation += delta * deg_to_rad(-20)
	%Layer04.rotation += delta * deg_to_rad(30)




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
	ModulateTween.tween_property(%Layer01, "modulate:a", alpha, time)
	ModulateTween.tween_property(%Layer02, "modulate:a", alpha, time)
	ModulateTween.tween_property(%Layer03, "modulate:a", alpha, time)
	ModulateTween.tween_property(%Layer04, "modulate:a", alpha, time)


func set_tween() -> void:
	if ModulateTween:
		ModulateTween.kill()
	ModulateTween = self.create_tween().set_parallel(true)
