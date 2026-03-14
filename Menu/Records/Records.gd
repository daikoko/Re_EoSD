extends Control

const TEXT_FILE := "res://Menu/_Text/MenuText.json"
const RECORD_DISPLAY := preload("res://Menu/Records/RecordDisplay.tscn")

var menu_active:bool

var records_index:int = 1
var records_main:Array[RecordFile]
var records_extra:Array[RecordFile]
var records_phantasm:Array[RecordFile]

var FocusTargetDecoy:Control
var FocusTargetMain:Control
var FocusTargetExtra:Control
var FocusTargetPhantasm:Control

signal back




func _ready():
	toggle_buttons(false)
	place_text()
	
	FocusTargetDecoy    = %Decoy
	FocusTargetMain     = %Decoy
	FocusTargetExtra    = %Decoy
	FocusTargetPhantasm = %Decoy
	
	%LabelMain.show()
	%LabelExtra.hide()
	%LabelPhantasm.hide()
	
	%RecordsMain.show()
	%RecordsExtra.hide()
	%RecordsPhantasm.hide()
	
	records_main =     GlobalSystem.get_records_main()
	records_extra =    GlobalSystem.get_records_extra()
	records_phantasm = GlobalSystem.get_records_phantasm()
	create_record_list()


func _process(_delta:float) -> void:
	if !Input.is_action_pressed("ui_left"):
		%Left.button_pressed = false
	if !Input.is_action_pressed("ui_right"):
		%Right.button_pressed = false


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
	%Animator.play("Load_In")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	change_index(0)


func load_out() -> void:
	toggle_buttons(false)
	
	%Animator.play("Load_Out")




func toggle_buttons(enable:bool) -> void:
	menu_active = enable


func place_text() -> void:
	var TextDict:Dictionary = GlobalSystem.get_json_dict(TEXT_FILE)
	
	%Title.text         = TextDict["records"]["title_01"]
	%LabelMain.text     = TextDict["records"]["label_01"]
	%LabelExtra.text    = TextDict["records"]["label_02"]
	%LabelPhantasm.text = TextDict["records"]["label_03"]
	%Top.set_label_rank(       TextDict["records"]["label_04"])
	%Top.set_label_name(       TextDict["records"]["label_05"])
	%Top.set_label_character(  TextDict["records"]["label_06"])
	%Top.set_label_difficulty( TextDict["records"]["label_07"])
	%Top.set_label_stage(      TextDict["records"]["label_08"])
	%Top.set_label_score(      TextDict["records"]["label_09"])
	%Top.set_label_date(       TextDict["records"]["label_10"])


func create_record_list() -> void:
	var prev_record:Button = null
	
	for i in records_main.size():
		var record = RECORD_DISPLAY.instantiate()
		record.set_record(i + 1, records_main[i])
		record.disabled = false
		
		%RecordsMain/List.add_child(record)
		if i == 0:
			FocusTargetMain = record
		else:
			prev_record.focus_neighbor_bottom = prev_record.get_path_to(record)
			record.focus_neighbor_top = record.get_path_to(prev_record)
		prev_record = record
	
	for i in records_extra.size():
		var record = RECORD_DISPLAY.instantiate()
		record.set_record(i + 1, records_extra[i])
		record.disabled = false
		
		%RecordsExtra/List.add_child(record)
		if i == 0:
			FocusTargetExtra = record
		else:
			prev_record.focus_neighbor_bottom = prev_record.get_path_to(record)
			record.focus_neighbor_top = record.get_path_to(prev_record)
		prev_record = record
	
	for i in records_phantasm.size():
		var record = RECORD_DISPLAY.instantiate()
		record.set_record(i + 1, records_phantasm[i])
		record.disabled = false
		
		%RecordsPhantasm/List.add_child(record)
		if i == 0:
			FocusTargetPhantasm = record
		else:
			prev_record.focus_neighbor_bottom = prev_record.get_path_to(record)
			record.focus_neighbor_top = record.get_path_to(prev_record)
		prev_record = record


func change_index(turn:int) -> void:
	%LabelMain.hide()
	%LabelExtra.hide()
	%LabelPhantasm.hide()
	%RecordsMain.hide()
	%RecordsExtra.hide()
	%RecordsPhantasm.hide()
	
	records_index = wrapi(records_index + turn, 1, 4)
	if records_index == 1:
		%LabelMain.show()
		%RecordsMain.show()
		FocusTargetMain.grab_focus()
	elif records_index == 2:
		%LabelExtra.show()
		%RecordsExtra.show()
		FocusTargetExtra.grab_focus()
	elif records_index == 3:
		%LabelPhantasm.show()
		%RecordsPhantasm.show()
		FocusTargetPhantasm.grab_focus()
