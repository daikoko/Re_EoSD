extends CanvasLayer

const SHOW_TIME := 0.2
const HIDE_TIME := 0.2
const MAIN_HIDE := Vector2(10, 200)
const MAIN_SHOW := Vector2(10, 0)

const SIZE_Y := 170.0
const TIME := 0.2

var active:bool
var MainTween:Tween

signal text_shown
signal text_hidden




func _ready():
	self.active = false
	self.visible = true
	
	%MainPanel.position = MAIN_HIDE
	%MainPanel.modulate.a = 0
	
	%MainName.hide()
	%MainText.hide()
	%MainBorder.hide()




func new_text(name:String, text:String) -> void:
	%MainName.text = name
	%MainText.text = text


func show_panel() -> void:
	MainTween = create_main_tween()
	MainTween.set_parallel(true)
	MainTween.tween_property(%MainPanel, "position", MAIN_SHOW, SHOW_TIME)
	MainTween.tween_property(%MainPanel, "modulate:a", 1, SHOW_TIME)
	MainTween.finished.connect(_on_MainTween_finished_show)


func hide_panel() -> void:
	%MainName.hide()
	%MainText.hide()
	%MainBorder.hide()
	
	MainTween = create_main_tween()
	MainTween.set_parallel(true)
	MainTween.tween_property(%MainPanel, "position", MAIN_HIDE, HIDE_TIME)
	MainTween.tween_property(%MainPanel, "modulate:a", 0, HIDE_TIME)
	MainTween.finished.connect(_on_MainTween_finished_hide)




func create_main_tween() -> Tween:
	if MainTween:
		MainTween.kill()
	MainTween = create_tween()
	return MainTween


func _on_MainTween_finished_show() -> void:
	self.active = true
	text_shown.emit()
	
	%MainName.show()
	%MainText.show()
	%MainBorder.show()


func _on_MainTween_finished_hide() -> void:
	self.active = false
	text_hidden.emit()
