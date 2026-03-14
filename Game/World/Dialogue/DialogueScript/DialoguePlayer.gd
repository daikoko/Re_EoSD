extends CanvasLayer

const DIALOGUE_PATH := "res://Game/World/Dialogue/DialogueList/Dialogue_"

var level_key:int
var active_to_user:bool = false

var dialogue_script:BossEvent_Dialogue = null
var dialogue:Dictionary
var dialogue_keys:Array
var dialogue_index:int = -1
var skip_dialogue:bool
var quick_dialogue:bool

signal user_next




func _ready():
	GlobalStage.request_dialogue.connect(_on_GlobalStage_request_dialogue)


func _process(_delta):
	if Input.is_action_pressed("dialogue_skip") and active_to_user:
		quick_dialogue = true
		emit_signal("user_next")
		
		set_process(false)
		await %SkipTimer.timeout
		
		set_process(true)


func _input(event):
	if event.is_action_pressed("dialogue_next") and active_to_user:
		quick_dialogue = false
		emit_signal("user_next")




func run_dialogue(dialogue_name:String, shot_enable:bool) -> void:
	# print(dialogue_name)
	
	GlobalStage.dialogue_start.emit(shot_enable)
	
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		skip_dialogue = true
	else:
		skip_dialogue = false
	
	var file_name = DIALOGUE_PATH + dialogue_name + ".json"
	dialogue = GlobalSystem.get_json_dict(file_name)
	dialogue_keys = dialogue.keys()
	dialogue_index = -1
	
	active_to_user = true
	next_dialogue()




func next_dialogue() -> void:
	dialogue_index += 1
	if dialogue_index == dialogue_keys.size():
		end_dialogue()
		return
	elif dialogue_index > dialogue_keys.size():
		return
	
	var current:Dictionary = dialogue[dialogue_keys[dialogue_index]]
	# print(current)
	# 
	# if dialogue_script == null:
	# 	print("Warning")
	
	match current["type"]:
		"enter":
			play_enter(current)
		"exit":
			play_exit(current)
		"dialogue":
			play_dialogue(current)
		"title":
			play_title(current)
		"event":
			play_event(current)


func end_dialogue() -> void:
	# print("Dialogue End")
	# print(" ")
	
	active_to_user = false
	
	%TextHandler.hide_all()
	%PortraitHandler.deactivate_all()
	await get_tree().process_frame
	
	dialogue_script.play_event("end")
	GlobalStage.dialogue_end.emit()


func play_enter(section:Dictionary) -> void:
	if skip_dialogue:
		next_dialogue()
		return
	
	%PortraitHandler.sprite_enter(
		section["identity"], 
		section["configuration"]
	)
	
	await get_tree().process_frame
	
	next_dialogue()


func play_exit(section:Dictionary) -> void:
	if skip_dialogue:
		next_dialogue()
		return
	
	%PortraitHandler.sprite_exit(
		section["identity"]
	)
	
	await get_tree().process_frame
	
	next_dialogue()


func play_dialogue(section:Dictionary) -> void:
	if skip_dialogue:
		next_dialogue()
		return
	
	%TextHandler.new_text(
		section["name"], 
		section["text"].replace("\n", " ")
	)
	%PortraitHandler.new_expression(
		section["identity"], 
		section["expression"],
		quick_dialogue
	)
	
	if %TextHandler.active == false:
		%TextHandler.show_main()
	
	await self.user_next
	
	%Sound.play()
	next_dialogue()


func play_title(section:Dictionary) -> void:
	if skip_dialogue:
		next_dialogue()
		return
	
	%TextHandler.show_side(
		section["name"], 
		section["text"]
	)
	
	await get_tree().process_frame
	
	next_dialogue()


func play_event(section:Dictionary) -> void:
	active_to_user = false
	if section["pause"] == "true":
		%TextHandler.hide_all()
		%PortraitHandler.unfocus_all()
	dialogue_script.play_event(
		section["event_name"]
	)
	
	await dialogue_script.dialogue_event_ended
	
	active_to_user = true
	next_dialogue()




func _on_GlobalStage_request_dialogue(dialogue_name:String, script:BossEvent_Dialogue, shot_enable:bool):
	dialogue_script = script
	run_dialogue(dialogue_name, shot_enable)
