extends AudioStreamPlayer

@export var music:MusicData




func _ready():
	GlobalSettings.settings_changed.connect(_on_GlobalSettings_settings_changed)
	
	self.volume_db = GlobalSettings.get_volume_music()
	if music != null:
		self.stream = music.music




func set_music(data:MusicData) -> void:
	self.stop()
	
	self.music = data
	self.stream = data.music


func pause() -> void:
	self.stream_paused = true


func resume() -> void:
	self.stream_paused = false




func _on_GlobalSettings_settings_changed():
	self.volume_db = GlobalSettings.get_volume_music()
