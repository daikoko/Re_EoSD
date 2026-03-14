extends Button

var id:int
var track:MusicData

signal selected(id, track)
signal deselected




func set_track(number:int, track:MusicData) -> void:
	self.id = number
	self.track = track
	
	%Number.text = (str(number) + ".")
	%Name.text = track.get_music_name()




func _on_Self_toggled(toggled_on:bool) -> void:
	if toggled_on:
		selected.emit(id, track)
	else:
		deselected.emit()


func _on_MusicRoom_deselect_all(id:int=0):
	if self.id == id:
		return
	
	self.button_pressed = false
