extends Control

const TEXT := "res://Game/_Text/GameText.json"
const TIME := 0.35
const SIZE_Y := 450.0

signal next




func _ready():
	place_text()


func hide_menu() -> void:
	self.visible = false
	toggle_buttons(false)
	%Animator.play("MenuStage_Out")


func show_menu(data:Dictionary) -> void:
	self.visible = true
	
	var base_score =  data["score_stage"]
	var graze_bonus = data["graze"] * GlobalStage.BONUS["extra_graze"]
	var clear_bonus = data["clear_bonus"]
	
	%MenuStage_Score.text = str(base_score)
	%MenuStage_Graze.text = "+ " + str(graze_bonus)
	%MenuStage_Clear.text = "+ " + str(clear_bonus)
	
	GlobalPlayer.bonus_graze_get.emit(graze_bonus)
	GlobalPlayer.bonus_clear_get.emit(clear_bonus)
	%MenuStage_Total.text = str(base_score + graze_bonus + clear_bonus)
	
	Debug.display_score()
	
	%Animator.play("MenuStage_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	%MenuStage_Next.grab_focus()




func toggle_buttons(enable:bool) -> void:
	%MenuStage_Next.disabled = !enable


func place_text() -> void:
	var text_dict = GlobalSystem.get_json_dict(TEXT)
	%MenuStage_Title.text =      text_dict["stage"]["title_01"]
	%MenuStage_ScoreLabel.text = text_dict["stage"]["label_01"]
	%MenuStage_ClearLabel.text = text_dict["stage"]["label_02"]
	%MenuStage_GrazeLabel.text = text_dict["stage"]["label_03"]
	%MenuStage_TotalLabel.text = text_dict["stage"]["label_04"]
	%MenuStage_Next.text =       text_dict["stage"]["option_01"]


func _on_MenuStage_Next_pressed() -> void:
	next.emit()
	hide_menu()
	%Sound_Select02.play()
