extends Control

const TEXT := "res://Game/_Text/GameText.json"
const TIME := 0.35
const SIZE_Y := 450.0

signal finish




func _ready():
	place_text()


func hide_menu() -> void:
	self.visible = false
	toggle_buttons(false)
	%Animator.play("MenuGame_Out")


func show_menu(save:SaveFile) -> void:
	self.visible = true
	
	var spellcard_ratio
	if save.spells_passed == 0:
		spellcard_ratio = 0
	else:
		spellcard_ratio = float(save.spells_captured) / float(save.spells_passed)
	
	var add_lives    = 0 #save.additional_start_lives * GlobalSettings.ADDITIONAL_LIVES_PENALTY
	var add_bombs    = 0 #save.additional_start_bombs * GlobalSettings.ADDITIONAL_BOMBS_PENALTY
	var add_captures = spellcard_ratio * GlobalStage.BONUS["spellcards_captured"]
	
	var score_base = save.score
	var score_bonus = roundi(score_base * (add_lives + add_bombs + add_captures))
	var score_total = score_base + score_bonus
	
	%MenuGame_Score.text = str(save.score)
	%MenuGame_Lives.text = "- " + str(abs(int(add_lives    * 100))) + " %"
	%MenuGame_Bombs.text = "- " + str(abs(int(add_bombs    * 100))) + " %"
	%MenuGame_Spell.text = "+ " + str(abs(int(add_captures * 100))) + " %"
	
	%MenuGame_Total.text = str(score_total)
	GlobalPlayer.bonus_clear_get.emit(score_bonus)
	
	%Animator.play("MenuGame_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	%MenuGame_Next.grab_focus()




func toggle_buttons(enable:bool) -> void:
	%MenuGame_Next.disabled = !enable


func place_text() -> void:
	var text_dict = GlobalSystem.get_json_dict(TEXT)
	%MenuGame_Title.text =      text_dict["game"]["title_01"]
	%MenuGame_ScoreLabel.text = text_dict["game"]["label_01"]
	%MenuGame_LivesLabel.text = text_dict["game"]["label_02"]
	%MenuGame_BombsLabel.text = text_dict["game"]["label_03"]
	%MenuGame_SpellLabel.text = text_dict["game"]["label_04"]
	%MenuGame_TotalLabel.text = text_dict["game"]["label_05"]
	%MenuGame_Next.text =       text_dict["game"]["option_01"]




func _on_MenuGame_Next_pressed() -> void:
	finish.emit()
	hide_menu()
	%Sound_Select03.play()
