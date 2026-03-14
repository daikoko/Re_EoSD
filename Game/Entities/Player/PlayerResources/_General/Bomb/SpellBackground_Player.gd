extends Background




func _ready():
	%ColorRect.modulate.a = 0
	fixed_fade_in()




func fixed_fade_in():
	var BackgroundTween = create_tween()
	
	BackgroundTween.tween_property(%ColorRect, "modulate:a", 1.0, 0.8)


func fixed_fade_out():
	var BackgroundTween = create_tween()
	
	BackgroundTween.finished.connect(_on_BackgroundTween_finished)
	BackgroundTween.tween_property(%ColorRect, "modulate:a", 0.0, 1.2)




func _on_BackgroundTween_finished():
	queue_free()
