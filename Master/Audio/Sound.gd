extends AudioStreamPlayer




func _ready():
	GlobalSettings.settings_changed.connect(_on_GlobalSettings_settings_changed)
	self.volume_db = GlobalSettings.get_volume_sound()




func _on_GlobalSettings_settings_changed():
	self.volume_db = GlobalSettings.get_volume_sound()
