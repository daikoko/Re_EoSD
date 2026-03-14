extends CanvasLayer

signal intro_finished




func _ready():
	%MusicName.modulate.a = 0
	%SpellControl.modulate.a = 0




func play_intro(name:String, title:String, description:String):
	%IntroName.text =        name
	%IntroTitle.text =       title
	%IntroDescription.text = description
	%IntroAnimator.play("Intro_In")


func play_music(name:String):
	%MusicName.text = name
	%MusicAnimator.play("Music_In")


func play_flash_activated(spell_name:String) -> void:
	if GlobalStage.is_current_player_bomb():
		return
	
	if %SpellFlashTimer.time_left == 0:
		%SpellName.text = spell_name
		center_spell_label()
		
		%SpellAnimator.play("Flash_Start")
		%SpellFlashTimer.start()
	
	else:
		%SpellFlashTimer.start()


func play_bomb_activated(spell_name:String) -> void:
	%SpellFlashTimer.stop()
	
	%SpellName.text = spell_name
	center_spell_label()
	
	%SpellAnimator.play("Bomb_Start")


func play_bomb_deactivated() -> void:
	%SpellAnimator.play("Bomb_End")


func center_spell_label() -> void:
	await get_tree().process_frame
	%SpellName.pivot_offset = %SpellName.size / 2




func _on_IntroAnimator_animation_finished(_anim_name):
	intro_finished.emit()


func _on_SpellFlashTimer_timeout() -> void:
	%SpellAnimator.play("Flash_End")
