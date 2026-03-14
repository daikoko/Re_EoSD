extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"
const SELECT_MUSIC_BUTTON := preload("res://Menu/Musics/Main/SelectMusicButton.tscn")

@export var track_list:Array[MusicData]

var menu_active:bool

var FocusTargetTrack:Control

signal deselect_all(id)
signal loaded
signal back




func _ready():
	toggle_buttons(false)
	place_text()
	
	load_tracks()


func _input(event):
	if menu_active == false:
		return
	
	if event.is_action_pressed("menu_escape"):
		back.emit()
		%Sound_Select04.play()




func load_in() -> void:
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetTrack.grab_focus()
	loaded.emit()


func load_out() -> void:
	toggle_buttons(false)
	self.emit_signal("deselect_all")
	
	%Animator.play("Load_Out")




func toggle_buttons(enable:bool) -> void:
	menu_active = enable


func place_text() -> void:
	var TextDict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%Title.text =      TextDict["music"]["title_01"]


func load_tracks() -> void:
	var prev_button:Button = null
	
	var valid_tracks = []
	for track in track_list:
		if track.flag_check():
			valid_tracks.append(track)
		else:
			pass
	
	for i in valid_tracks.size():
		var button = SELECT_MUSIC_BUTTON.instantiate()
		button.set_track(i + 1, valid_tracks[i])
		button.connect("selected", _on_SelectMusicButton_selected)
		button.connect("deselected", _on_SelectMusicButton_deselected)
		self.connect("deselect_all", button._on_MusicRoom_deselect_all)
		
		%TrackList.add_child(button)
		if i == 0:
			FocusTargetTrack = button
		else:
			prev_button.focus_neighbor_bottom = prev_button.get_path_to(button)
			button.focus_neighbor_top = button.get_path_to(prev_button)
		prev_button = button




func _on_SelectMusicButton_selected(id, track):
	self.emit_signal("deselect_all", id)
	
	%Music.set_music(track)
	%Music.play()


func _on_SelectMusicButton_deselected():
	%Music.stop()
