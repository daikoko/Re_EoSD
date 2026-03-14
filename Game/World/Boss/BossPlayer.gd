extends CanvasLayer

var Boss_Dict:Dictionary = {}
var Event_List:Array = []
var CurrentEvent:BossEvent
var phase:int = -1

var boss_start:bool = false
var boss_immunity:bool = true
var spell_bonus_valid:bool = true

var timeout:bool = false

var health:int = 0
var time:int = 0

var damage_recorder:int




func _ready():
	GlobalStage.boss_hit.connect(_on_GlobalLevel_boss_hit)
	GlobalPlayer.player_death.connect(_on_GlobalPlayer_player_death)
	GlobalPlayer.player_over.connect(_on_GlobalPlayer_player_over)
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_used_bomb)
	
	set_process(false)


func _process(_delta):
	%EventHandler.update_time(%SpellTimer.time_left)




func start_boss(boss_data:BossData) -> void:
	Event_List = boss_data.get_events()
	
	if Event_List.size() == 0:
		print("No Events!")
		
		await get_tree().process_frame
		GlobalStage.boss_end.emit()
		
		return
	
	CurrentEvent = null
	phase = -1
	
	boss_start = false
	boss_immunity = true
	
	next_phase()




func next_phase() -> void:
	phase += 1
	# print(phase)
	
	if phase == Event_List.size():
		end_boss()
		return
	
	CurrentEvent = Event_List[phase]
	
	# print(" ")
	# print("Next Phase")
	# print(" ")
	
	var event_type = CurrentEvent.get_type()
	if event_type == BossEvent.TYPE.DIALOGUE:
		play_dialogue(CurrentEvent)
	elif event_type == BossEvent.TYPE.NON:
		play_non(CurrentEvent)
	elif event_type == BossEvent.TYPE.SPELL:
		play_spell(CurrentEvent)


func play_dialogue(dialogue:BossEvent_Dialogue) -> void:
	dialogue.play_dialogue(%EventHandler, Boss_Dict)
	await dialogue.event_ended
	next_phase()


func play_non(Non:BossEvent_Non) -> void:
	health = Non.health
	
	var fill_time = Non.prepare(%EventHandler, Boss_Dict)
	%EventHandler.fill_bars_non(fill_time, health)
	
	%FillTimer.wait_time = fill_time
	%FillTimer.start()
	await %FillTimer.timeout
	
	Non.start()
	await Non.non_started
	
	boss_immunity = false
	%ImmunityTimer.start()
	%RecordTimer.start()


func play_spell(Spell:BossEvent_Spell) -> void:
	spell_bonus_valid = true
	
	health = Spell.health
	time = Spell.time
	
	var fill_time = Spell.prepare(%EventHandler, Boss_Dict)
	%EventHandler.fill_bars_spell(fill_time, health, time)
	
	%FillTimer.wait_time = fill_time
	%FillTimer.start()
	await %FillTimer.timeout
	
	if Spell.timeout:
		timeout = true
		%EventHandler.set_bars_timeout()
	if Spell.warning:
		pass
	
	Spell.start()
	await Spell.spell_started
	
	set_process(true)
	%SpellTimer.wait_time = time
	%SpellTimer.set_paused(false)
	%SpellTimer.start()
	
	boss_immunity = false
	%ImmunityTimer.start()
	%RecordTimer.start()


func end_attack_phase() -> void:
	boss_immunity = true
	%RecordTimer.stop()
	
	set_process(false)
	%SpellTimer.set_paused(true)
	
	timeout = false
	%EventHandler.reset_bars()
	
	CurrentEvent.stop()
	await CurrentEvent.event_ended
	
	next_phase()


func end_boss() -> void:
	GlobalStage.boss_end.emit()
	
	var Buffer:Dictionary = {}
	for key in Boss_Dict:
		if Boss_Dict[key] == null:
			continue
		Buffer[key] = Boss_Dict[key]
		Boss_Dict[key] = null
	
	var DelayTimer = GlobalStage.create_timer(self, 1.0)
	DelayTimer.start()
	await DelayTimer.timeout
	
	DelayTimer.queue_free()
	for key in Buffer:
		Buffer[key].queue_free()
	
	Event_List = []


func count_spells() -> void:
	var count = 0
	
	for Event in Event_List:
		if Event.get_type() == BossEvent.TYPE.SPELL:
			count += 1
	
	%EventHandler.fill_spells(count)


func calculate_bonus(bonus_base:int, bonus_extra:int) -> void:
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		return
	
	var time_factor
	if CurrentEvent.timeout:
		time_factor = 1.0
	else:
		time_factor = %SpellTimer.time_left / %SpellTimer.wait_time
	
	if time_factor > 0 and spell_bonus_valid:
		var total_bonus = int(bonus_base + (bonus_extra * time_factor))
		%EventHandler.display_bonus(total_bonus)
		GlobalPlayer.spellcard_passed.emit(true)
		GlobalPlayer.bonus_spell_get.emit(total_bonus)
	else:
		%EventHandler.display_bonus()
		GlobalPlayer.spellcard_passed.emit(false)




func _on_GlobalLevel_boss_hit(damage:int):
	if boss_immunity == true:
		return
	if timeout == true:
		return
	
	if not %ImmunityTimer.is_stopped():
		var time_modifier = %ImmunityTimer.time_left / %ImmunityTimer.wait_time
		damage = damage * (1.0 - time_modifier)
	
	health = clampi(health - damage, 0, %Health.max_value)
	%EventHandler.update_health(health)
	
	damage_recorder += damage
	
	if damage > 0:
		GlobalStage.boss_hit_passed.emit()
	elif damage < 0:
		GlobalStage.boss_heal_passed.emit()
	
	if health <= 0:
		end_attack_phase()


func _on_SpellTimer_timeout():
	end_attack_phase()


func _on_GlobalPlayer_player_death():
	spell_bonus_valid = false


func _on_GlobalPlayer_player_over():
	spell_bonus_valid = false


func _on_GlobalPlayer_player_used_bomb(_spellname:String):
	spell_bonus_valid = false


func _on_EventHandler_request_count_spells():
	count_spells()


func _on_EventHandler_request_calculate_bonus(bonus,extra):
	calculate_bonus(bonus, extra)


func _on_RecordTimer_timeout() -> void:
	# print("Boss Damage: " + str(damage_recorder) + " dps")
	damage_recorder = 0
