extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"

var mode:int
enum MODE {
	MAIN,
	EXTRA,
	PHANTASM
}

var menu_active:bool = false

var FocusTargetDifficulty:Control

var MoveTarget:BaseButton
var MoveDuplicate:BaseButton
var back_position:Vector2

var shift_presses:int

signal back
signal selected(difficulty)




func _ready():
	toggle_buttons(false)
	place_text()
	
	FocusTargetDifficulty = %EasyButton
	%EasyName.add_theme_color_override(
		"font_outline_color", 
		GlobalSettings.get_difficulty_color(GlobalSettings.DIFFICULTY.EASY)
	)
	%NormalName.add_theme_color_override(
		"font_outline_color", 
		GlobalSettings.get_difficulty_color(GlobalSettings.DIFFICULTY.NORMAL)
	)
	%HardName.add_theme_color_override(
		"font_outline_color", 
		GlobalSettings.get_difficulty_color(GlobalSettings.DIFFICULTY.HARD)
	)
	%LunaticName.add_theme_color_override(
		"font_outline_color", 
		GlobalSettings.get_difficulty_color(GlobalSettings.DIFFICULTY.LUNATIC)
	)
	
	%ExtraName.add_theme_color_override(
		"font_outline_color", 
		GlobalSettings.get_difficulty_color(GlobalSettings.DIFFICULTY.LUNATIC)
	)
	
	%PhantasmName.add_theme_color_override(
		"font_outline_color", 
		GlobalSettings.get_difficulty_color(GlobalSettings.DIFFICULTY.PHANTASM)
	)
	
	%PhantasmLayer.hide()


func _input(event):
	if menu_active == false:
		return
	
	if event.is_action_pressed("menu_escape"):
		back.emit()
		%Sound_Select04.play()
	
	if event.is_action_pressed("game_shift"):
		check_shift()




func start() -> void:
	toggle_buttons(true)
	FocusTargetDifficulty.grab_focus()


func load_in(section:int) -> void:
	if section == GlobalSettings.SECTION.MAIN:
		%Main.show()
		%Extra.hide()
		%Phantasm.hide()
		FocusTargetDifficulty = %EasyButton
		mode = MODE.MAIN
	
	if section == GlobalSettings.SECTION.EXTRA:
		%Main.hide()
		%Extra.show()
		%Phantasm.hide()
		FocusTargetDifficulty = %ExtraButton
		mode = MODE.EXTRA
	
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetDifficulty.grab_focus()


func load_in_back() -> void:
	move_out()
	
	%Animator.play("Load_In_Back")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetDifficulty.grab_focus()


func load_out() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out")


func load_out_next() -> void:
	toggle_buttons(false)
	move_in()
	
	%Animator.play("Load_Out_Next")




func toggle_buttons(enable:bool) -> void:
	menu_active = enable
	
	%EasyButton.disabled =    !enable
	%NormalButton.disabled =  !enable
	%HardButton.disabled =    !enable
	%LunaticButton.disabled = !enable
	%ExtraButton.disabled =    !enable
	%PhantasmButton.disabled = !enable


func place_text() -> void:
	var text_dict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%Title.text        = text_dict["difficulty"]["title_01"]
	%EasyName.text     = text_dict["difficulty"]["option_01"]
	%NormalName.text   = text_dict["difficulty"]["option_02"]
	%HardName.text     = text_dict["difficulty"]["option_03"]
	%LunaticName.text  = text_dict["difficulty"]["option_04"]
	%ExtraName.text    = text_dict["difficulty"]["option_05"]
	%PhantasmName.text = text_dict["difficulty"]["option_06"]
	%EasyText.text     = text_dict["difficulty"]["label_01"]
	%NormalText.text   = text_dict["difficulty"]["label_02"]
	%HardText.text     = text_dict["difficulty"]["label_03"]
	%LunaticText.text  = text_dict["difficulty"]["label_04"]
	%ExtraText.text    = text_dict["difficulty"]["label_05"]
	%PhantasmText.text = text_dict["difficulty"]["label_06"]


func move_in() -> void:
	MoveDuplicate = MoveTarget.duplicate()
	MoveDuplicate.position = MoveTarget.global_position
	self.add_child(MoveDuplicate)
	
	var MoveTween = create_tween()
	MoveTween.tween_property(MoveDuplicate, "position", Vector2(660, 170), 0.4)
	
	MoveTarget.modulate.a = 0
	back_position = MoveTarget.global_position


func move_out() -> void:
	var MoveTween = create_tween()
	MoveTween.tween_property(MoveDuplicate, "position", back_position, 0.2)
	await MoveTween.finished
	
	MoveTarget.modulate.a = 1
	MoveDuplicate.queue_free()


func check_shift() -> void:
	if mode != MODE.EXTRA or not GlobalSettings.flag_check("Passed_ExtraSeries"):
		return
	
	if shift_presses < 3:
		shift_presses += 1
		%ShiftTimer.start()
	else:
		show_phantasm()


func show_phantasm() -> void:
	toggle_buttons(false)
	
	%PhantasmLayer.show()
	%PhantasmCover.texture = get_viewport_texture()
	
	%Main.hide()
	%Extra.hide()
	%Phantasm.show()
	FocusTargetDifficulty = %PhantasmButton
	mode = MODE.PHANTASM
	
	%PhantasmCover.material.set_shader_parameter("distortion_intensity", 0.0)
	%PhantasmCover.material.set_shader_parameter("distortion_alpha",     1.0)
	%PhantasmSound.play()
	
	var time = 1.0
	var LoadInTween = create_tween().set_parallel()
	LoadInTween.tween_property(%PhantasmCover.material, "shader_parameter/distortion_intensity",  2.0, time)
	LoadInTween.tween_property(%PhantasmCover.material, "shader_parameter/distortion_alpha",      0.0, time)
	await LoadInTween.finished
	
	%PhantasmLayer.hide()
	
	toggle_buttons(true)
	FocusTargetDifficulty.grab_focus()


func get_viewport_texture() -> Texture2D:
	var texture:Image = get_viewport().get_texture().get_image()
	var image:ImageTexture = ImageTexture.create_from_image(texture)
	
	return image




func _on_EasyButton_pressed():
	FocusTargetDifficulty = %EasyButton
	MoveTarget = %EasyButton
	
	selected.emit(GlobalSettings.DIFFICULTY.EASY)
	%Sound_Select02.play()


func _on_NormalButton_pressed():
	FocusTargetDifficulty = %NormalButton
	MoveTarget = %NormalButton
	
	selected.emit(GlobalSettings.DIFFICULTY.NORMAL)
	%Sound_Select02.play()


func _on_HardButton_pressed():
	FocusTargetDifficulty = %HardButton
	MoveTarget = %HardButton
	
	selected.emit(GlobalSettings.DIFFICULTY.HARD)
	%Sound_Select02.play()


func _on_LunaticButton_pressed():
	FocusTargetDifficulty = %LunaticButton
	MoveTarget = %LunaticButton
	
	selected.emit(GlobalSettings.DIFFICULTY.LUNATIC)
	%Sound_Select02.play()


func _on_ExtraButton_pressed():
	FocusTargetDifficulty = %ExtraButton
	MoveTarget = %ExtraButton
	
	selected.emit(GlobalSettings.DIFFICULTY.EXTRA)
	%Sound_Select02.play()


func _on_PhantasmButton_pressed() -> void:
	FocusTargetDifficulty = %PhantasmButton
	MoveTarget = %PhantasmButton
	
	selected.emit(GlobalSettings.DIFFICULTY.PHANTASM)
	%Sound_Select02.play()


func _on_ShiftTimer_timeout() -> void:
	shift_presses = 0
