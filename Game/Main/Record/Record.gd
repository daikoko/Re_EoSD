extends CanvasLayer

const RECORD_DISPLAY_SHORT := preload("res://Game/Main/Record/RecordDisplayShort.tscn")

enum MODE {
	GAME_OVER,
	GAME_FINISH
}
enum SELECTION_MODE {
	RECORD,
	NAME
}

var selection_mode:int

var rank:int
var save:SaveFile

var disabled:bool = true

var FocusTargetRecord:Control
var FocusTargetName:Control

signal record_finish(mode)




func _ready():
	visible = false
	toggle_buttons(false)
	
	FocusTargetName = %Name_Edit


func _input(event):
	if disabled:
		return
	
	if selection_mode == SELECTION_MODE.RECORD:
		if event.is_action_pressed("ui_right"):
			selection_mode = SELECTION_MODE.NAME
			FocusTargetName.grab_focus()
	elif selection_mode == SELECTION_MODE.NAME:
		if event.is_action_pressed("ui_left"):
			selection_mode = SELECTION_MODE.RECORD
			FocusTargetRecord.grab_focus()
		elif event.is_action_pressed("menu_accept"):
			if event.is_action_pressed("game_escape"):
				return
			toggle_buttons(false)
			save_and_continue()




func start(save:SaveFile) -> void:
	create_record_list(save)
	self.save = save
	
	%Name_Edit.text = GlobalSettings.get_last_record()
	
	visible = true
	%Animator.play("Records_Start")
	await %Animator.animation_finished
	
	toggle_buttons(true)
	
	selection_mode = SELECTION_MODE.NAME
	FocusTargetRecord.grab_focus()
	await get_tree().process_frame
	
	FocusTargetName.grab_focus()


func play_music() -> void:
	%Music.play()


func stop_music() -> void:
	%Music.stop()




func toggle_buttons(enable:bool) -> void:
	disabled = !enable
	
	%Name_Edit.editable = enable


func load_record(save:SaveFile) -> Array[RecordFile]:
	var records:Array[RecordFile]
	if save.section == GlobalSettings.SECTION.MAIN:
		records = GlobalSystem.get_records_main()
	elif save.section == GlobalSettings.SECTION.EXTRA:
		records = GlobalSystem.get_records_extra()
	elif save.section == GlobalSettings.SECTION.PHANTASM:
		records = GlobalSystem.get_records_phantasm()
	
	var fit:bool = false
	var score:int = save.score
	var temp_record = GlobalSystem.create_record_file(save, "-----")
	for i in records.size():
		if score > records[i].score:
			fit = true
			rank = i
			records.insert(i, temp_record)
			break
	if fit == false:
		rank = records.size()
		records.append(temp_record)
	
	return records


func create_record_list(save:SaveFile) -> void:
	var records:Array[RecordFile] = load_record(save)
	
	var prev_record:Button = null
	for i in records.size():
		var record = RECORD_DISPLAY_SHORT.instantiate()
		record.set_record(i + 1, records[i])
		%Rank_List.add_child(record)
		
		record.focus_neighbor_right = record.get_path_to(%Name_Edit)
		record.focus_next = record.get_path_to(%Name_Edit)
		if i == 0:
			record.focus_neighbor_top = "."
		else:
			prev_record.focus_neighbor_bottom = prev_record.get_path_to(record)
			record.focus_neighbor_top = record.get_path_to(prev_record)
		
		prev_record = record
		
		if i == rank:
			FocusTargetRecord = record


func save_and_continue() -> void:
	var record = GlobalSystem.create_record_file(save, %Name_Edit.text)
	GlobalSystem.save_record_file(record)
	
	GlobalSettings.update_last_record(%Name_Edit.text)
	
	toggle_buttons(false)
	record_finish.emit()
