extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"

enum MODE {
	LIVES,
	BOMBS,
	SOUND
}
var mode:int

var menu_active:bool

var volume_sound:int
var volume_music:int

signal back




func _ready():
	toggle_buttons(false)
	place_text()
	
	update_from_file()


func _process(_delta:float) -> void:
	if menu_active == false:
		return
	
	if %LivesDecoy.has_focus():
		mode = MODE.LIVES
		%LivesLeft.disabled  = false
		%LivesRight.disabled = false
		%BombsLeft.disabled  = true
		%BombsRight.disabled = true
	elif %BombsDecoy.has_focus():
		mode = MODE.BOMBS
		%LivesLeft.disabled  = true
		%LivesRight.disabled = true
		%BombsLeft.disabled  = false
		%BombsRight.disabled = false
	else:
		mode = MODE.SOUND
		%LivesLeft.disabled  = true
		%LivesRight.disabled = true
		%BombsLeft.disabled  = true
		%BombsRight.disabled = true
	
	if !Input.is_action_pressed("ui_left"):
		%LivesLeft.button_pressed = false
		%BombsLeft.button_pressed = false
	if !Input.is_action_pressed("ui_right"):
		%LivesRight.button_pressed = false
		%BombsRight.button_pressed = false


func _input(event):
	if menu_active == false:
		return
	
	if event.is_action_pressed("menu_escape"):
		back.emit()
		%Sound_Select04.play()
		
		return
	
	if mode == MODE.LIVES:
		if event.is_action_pressed("ui_left"):
			update_lives(-1)
			%LivesLeft.button_pressed = true
			%Sound_Select02.play()
		if event.is_action_pressed("ui_right"):
			update_lives(1)
			%LivesRight.button_pressed = true
			%Sound_Select02.play()
	
	elif mode == MODE.BOMBS:
		if event.is_action_pressed("ui_left"):
			update_bombs(-1)
			%BombsLeft.button_pressed = true
			%Sound_Select02.play()
		if event.is_action_pressed("ui_right"):
			update_bombs(1)
			%BombsRight.button_pressed = true
			%Sound_Select02.play()




func load_in() -> void:
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	%LivesDecoy.grab_focus()


func load_out() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out")




func toggle_buttons(enable:bool) -> void:
	menu_active = enable
	
	%SoundSlider.editable =    enable
	%MusicSlider.editable =    enable
	
	if enable == false:
		%LivesLeft.disabled  = true
		%LivesRight.disabled = true
		%BombsLeft.disabled  = true
		%BombsRight.disabled = true


func place_text() -> void:
	var TextDict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%Title.text =      TextDict["settings"]["title_01"]
	%LivesLabel.text = TextDict["settings"]["label_01"]
	%BombsLabel.text = TextDict["settings"]["label_02"]
	%SoundLabel.text = TextDict["settings"]["label_03"]
	%MusicLabel.text = TextDict["settings"]["label_04"]


func update_from_file() -> void:
	var SettingsDict:Dictionary = GlobalSettings.get_settings()
	
	%LivesDisplay.value = SettingsDict["additional_lives"]
	%BombsDisplay.value = SettingsDict["additional_lives"]
	self.volume_sound =   SettingsDict["volume_sound"]
	self.volume_music =   SettingsDict["volume_music"]
	
	%SoundSlider.value = volume_sound
	%MusicSlider.value = volume_music


func update_settings() -> void:
	var SettingsDict = {
		"additional_lives": %LivesDisplay.value,
		"additional_bombs": %BombsDisplay.value,
		"volume_sound":     self.volume_sound,
		"volume_music":     self.volume_music,
	}
	
	GlobalSettings.update_settings(SettingsDict)


func update_lives(amount:int) -> void:
	%LivesDisplay.value += amount
	update_settings()


func update_bombs(amount:int) -> void:
	%BombsDisplay.value += amount
	update_settings()


func update_sound(value:float) -> void:
	if %SoundSlider.value == %SoundSlider.min_value:
		volume_sound = -80
	else:
		volume_sound = %SoundSlider.value
	update_settings()
	%Sound_Select02.play()


func update_music(value:float) -> void:
	if %MusicSlider.value == %MusicSlider.min_value:
		volume_music = -80
	else:
		volume_music = %MusicSlider.value
	update_settings()
	%Sound_Select02.play()




func _on_SoundSlider_value_changed(value):
	update_sound(value)


func _on_MusicSlider_value_changed(value):
	update_music(value)
