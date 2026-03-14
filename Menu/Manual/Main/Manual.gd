extends Control

const TEXT_FILE        := "res://Menu/_Text/MenuText.json"
const TEXT_FILE_MANUAL := "res://Menu/Manual/_Text/ManualText.json"

const MAX_PAGES := 3
const POSITION_LEFT   := Vector2(-1280, 0)
const POSITION_CENTER := Vector2(    0, 0)
const POSITION_RIGHT  := Vector2( 1280, 0)
const MODULATE_INACTIVE := 0.0
const MODULATE_ACTIVE   := 1.0
const TIME := 0.2

const ROTATION_SPEED := 90.0

var menu_active:bool

var volume_sound:int
var volume_music:int

var page_index:int

@onready var FocusTargetDecoy = %Decoy
@onready var PageDict:Dictionary = {
	1: %Page01,
	2: %Page02,
	3: %Page03
}

signal back




func _ready():
	toggle_buttons(false)
	place_text()
	
	%Sprite01.play()
	%Sprite02.play()


func _process(delta:float) -> void:
	if !Input.is_action_pressed("ui_left"):
		%Left.button_pressed = false
	if !Input.is_action_pressed("ui_right"):
		%Right.button_pressed = false
	
	%Sprite03.rotation += deg_to_rad(ROTATION_SPEED) * delta
	%Sprite04.rotation += deg_to_rad(ROTATION_SPEED) * delta


func _input(event):
	if menu_active == false:
		return
	
	if event.is_action_pressed("menu_escape"):
		back.emit()
		%Sound_Select04.play()
	elif event.is_action_pressed("ui_left"):
		change_index(-1)
		%Left.button_pressed = true
		%Sound_Select02.play()
	elif event.is_action_pressed("ui_right"):
		change_index(1)
		%Right.button_pressed = true
		%Sound_Select02.play()




func load_in() -> void:
	set_index(1)
	
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	FocusTargetDecoy.grab_focus()


func load_out() -> void:
	menu_active = false
	
	%Animator.play("Load_Out")




func toggle_buttons(enable:bool) -> void:
	menu_active = enable


func place_text() -> void:
	var TextDict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	var TextDictManual:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE_MANUAL)
	
	%Title.text      =     TextDict["manual"]["title_01"]
	%ArrowLabel.text =     TextDictManual["page_01"]["text_01"].replace("\n", " ")
	%SpaceLabel.text =     TextDictManual["page_01"]["text_02"].replace("\n", " ")
	%EscapeLabel.text =    TextDictManual["page_01"]["text_03"].replace("\n", " ")
	%ShootLabel.text =     TextDictManual["page_01"]["text_04"].replace("\n", " ")
	%ShiftLabel.text =     TextDictManual["page_01"]["text_05"].replace("\n", " ")
	%BombLabel.text =      TextDictManual["page_01"]["text_06"].replace("\n", " ")
	%FlashLabel.text =     TextDictManual["page_01"]["text_07"].replace("\n", " ")
	%NextLabel.text =      TextDictManual["page_01"]["text_08"].replace("\n", " ")
	%SkipLabel.text =      TextDictManual["page_01"]["text_09"].replace("\n", " ")
	%LivesLabel.text =     TextDictManual["page_02"]["text_10"].replace("\n", " ")
	%BombsLabel.text =     TextDictManual["page_02"]["text_11"].replace("\n", " ")
	%PowerLabel.text =     TextDictManual["page_02"]["text_12"].replace("\n", " ")
	%GrazeLabel.text =     TextDictManual["page_02"]["text_13"].replace("\n", " ")
	%ScoreLabel.text =     TextDictManual["page_02"]["text_14"].replace("\n", " ")
	%SpellcardLabel.text = TextDictManual["page_02"]["text_15"].replace("\n", " ")
	%FocusLabel.text =     TextDictManual["page_02"]["text_16"].replace("\n", " ")
	%CasualLabel.text =    TextDictManual["page_03"]["text_17"].replace("\n", " ")
	%ArcadeLabel.text =    TextDictManual["page_03"]["text_18"].replace("\n", " ")
	%ExtraLabel.text =     TextDictManual["page_03"]["text_19"].replace("\n", " ")
	%PhantasmLabel.text =  TextDictManual["page_03"]["text_20"].replace("\n", " ")


func set_index(page_set:int):
	page_index = page_set
	%PageLabel.text = str(page_index) + "/" + str(MAX_PAGES)
	
	for key in PageDict:
		var page = PageDict[key]
		page.position = POSITION_RIGHT
		page.modulate.a = MODULATE_INACTIVE
	
	var page_active = PageDict[page_index]
	page_active.position = POSITION_CENTER
	page_active.modulate.a = MODULATE_ACTIVE


func change_index(turn:int):
	var page_index_prev = page_index
	var page_index_next = wrapi(page_index + turn, 1, MAX_PAGES + 1)
	
	page_index = page_index_next
	%PageLabel.text = str(page_index) + "/" + str(MAX_PAGES)
	
	var SelectionTweener = create_tween().set_parallel(true)
	SelectionTweener.finished.connect(_on_SelectionTween_finished)
	toggle_buttons(false)
	
	if turn == 1:
		var page_prev = PageDict[page_index_prev]
		page_prev.position = POSITION_CENTER
		page_prev.modulate.a = MODULATE_ACTIVE
		
		var page_next = PageDict[page_index_next]
		page_next.position = POSITION_RIGHT
		page_next.modulate.a = MODULATE_ACTIVE
		
		SelectionTweener.tween_property(page_prev, "position",   POSITION_LEFT,     TIME)
		SelectionTweener.tween_property(page_prev, "modulate:a", MODULATE_INACTIVE, TIME)
		
		SelectionTweener.tween_property(page_next, "position",   POSITION_CENTER,   TIME)
		SelectionTweener.tween_property(page_next, "modulate:a", MODULATE_ACTIVE,   TIME)
	
	if turn == -1:
		var page_prev = PageDict[page_index_prev]
		page_prev.position = POSITION_CENTER
		page_prev.modulate.a = MODULATE_ACTIVE
		
		var page_next = PageDict[page_index_next]
		page_next.position = POSITION_LEFT
		page_next.modulate.a = MODULATE_ACTIVE
		
		SelectionTweener.tween_property(page_prev, "position",   POSITION_RIGHT,    TIME)
		SelectionTweener.tween_property(page_prev, "modulate:a", MODULATE_INACTIVE, TIME)
		
		SelectionTweener.tween_property(page_next, "position",   POSITION_CENTER,   TIME)
		SelectionTweener.tween_property(page_next, "modulate:a", MODULATE_ACTIVE,   TIME)


func _on_SelectionTween_finished():
	toggle_buttons(true)
