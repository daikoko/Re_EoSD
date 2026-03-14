extends Background

const ROTATION_SPEED := 30.0

var ModulateTween:Tween




func _process(delta):
	%Main.rotation += deg_to_rad(ROTATION_SPEED * delta)




func hide_background() -> void:
	%Flash.hide()
	
	set_tween()
	ModulateTween.tween_property(%Main, "modulate:a", 0, 0)


func show_background() -> void:
	%Flash.show()
	
	set_tween()
	ModulateTween.tween_property(%Main, "modulate:a", 1, 0)


func fade_in(time:float=1.0) -> void:
	%Flash.show()
	%Flash.modulate.a = 1
	%Flash.scale = 0.8 * Vector2.ONE
	
	set_tween()
	ModulateTween.tween_property(%Main, "modulate:a", 1, time)
	ModulateTween.tween_property(%Flash, "modulate:a", 0, time * 3.0)
	ModulateTween.tween_property(%Flash, "scale", 2.0 * Vector2.ONE, time * 3.0)


func fade_out(time:float=2.0) -> void:
	%Flash.hide()
	
	set_tween()
	ModulateTween.tween_property(%Main, "modulate:a", 0, time)




func set_tween() -> void:
	if ModulateTween:
		ModulateTween.kill()
	ModulateTween = self.create_tween().set_parallel(true)
