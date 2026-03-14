extends TextureButton

signal selected(type)

var Shot:ShotData




func set_button(Shot:ShotData) -> void:
	%ShotName.text =        Shot.get_shot_name()
	%ShotDescription.text = Shot.get_shot_description()
	self.Shot = Shot




func _on_pressed() -> void:
	selected.emit(Shot)
