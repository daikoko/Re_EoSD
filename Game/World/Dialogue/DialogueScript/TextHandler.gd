extends CanvasLayer

const MAIN_TIME := 0.2
const MAIN_HIDE := Vector2(10, 800)
const MAIN_SHOW := Vector2(10, 600)

const SIDE_TIME := 0.4
const SIDE_HIDE := Vector2(370, 490)
const SIDE_SHOW := Vector2(270, 490)

const HIDE_TIME := 0.2

var active:bool = false
var MainTween:Tween
var SideTween:Tween

signal text_showed
signal text_hidden




func _ready():
	active = false
	
	%MainPanel.position = MAIN_HIDE
	%MainPanel.modulate.a = 0
	
	%SidePanel.position = SIDE_HIDE
	%SidePanel.modulate.a = 0
	
	%MainName.hide()
	%MainText.hide()
	%MainBorder.hide()
	%SideName.hide()
	%SideTitle.hide()




func new_text(name:String, text:String) -> void:
	%MainName.text = name
	%MainText.text = text


func show_main() -> void:
	active = true
	
	%MainName.show()
	%MainText.show()
	%MainBorder.show()
	%SideName.show()
	%SideTitle.show()
	
	MainTween = create_main_tween()
	MainTween.set_parallel(true)
	MainTween.tween_property(%MainPanel, "position", MAIN_SHOW, MAIN_TIME)
	MainTween.tween_property(%MainPanel, "modulate:a", 1, MAIN_TIME)
	MainTween.finished.connect(_on_PanelTween_finished_show)


func show_side(name:String, title:String, color:Color=Color(1,1,1,1)) -> void:
	%SideName.add_theme_color_override("font_color", color)
	%SideName.text = name
	%SideTitle.text = title
	
	SideTween = create_side_tween()
	SideTween.tween_property(%SidePanel, "position", SIDE_SHOW, SIDE_TIME)
	SideTween.parallel().tween_property(%SidePanel, "modulate:a", 1, SIDE_TIME)
	SideTween.tween_interval(2.0)
	SideTween.tween_property(%SidePanel, "position", SIDE_HIDE, SIDE_TIME)
	SideTween.parallel().tween_property(%SidePanel, "modulate:a", 0, SIDE_TIME)


func hide_all() -> void:
	active = false
	
	%MainName.hide()
	%MainText.hide()
	%MainBorder.hide()
	%SideName.hide()
	%SideTitle.hide()
	
	MainTween = create_main_tween()
	MainTween.set_parallel(true)
	MainTween.tween_property(%MainPanel, "position", MAIN_HIDE, HIDE_TIME)
	MainTween.tween_property(%MainPanel, "modulate:a", 0, HIDE_TIME)
	MainTween.finished.connect(_on_PanelTween_finished_hide)
	
	SideTween = create_side_tween()
	SideTween.set_parallel(true)
	SideTween.tween_property(%SidePanel, "position", SIDE_HIDE, HIDE_TIME)
	SideTween.tween_property(%SidePanel, "modulate:a", 0, HIDE_TIME)




func create_main_tween() -> Tween:
	if MainTween:
		MainTween.kill()
	MainTween = create_tween()
	return MainTween


func create_side_tween() -> Tween:
	if SideTween:
		SideTween.kill()
	SideTween = create_tween()
	return SideTween




func _on_PanelTween_finished_show():
	text_showed.emit()


func _on_PanelTween_finished_hide():
	text_hidden.emit()
