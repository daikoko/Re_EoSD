extends Control

const SPELL_HIDE_POSITION := Vector2(200,  72)
const SPELL_SHOW_POSITION := Vector2(40,  72)

const SPELL_PORTRAIT := preload("res://Game/Objects/Portrait/SpellPortrait.tscn")

signal request_count_spells()
signal request_calculate_bonus(base,extra)


func _ready():
	hide_bars()
	%Health.value = 0
	%Time.value = 0
	%Spells.value = 0
	
	%BonusContainer.position = Vector2.ZERO
	%BonusContainer.modulate.a = 0
	
	%SpellContainer.position = SPELL_HIDE_POSITION
	%SpellContainer.modulate.a = 0




func hide_bars():
	%BarsContainer.hide()


func show_bars():
	%BarsContainer.show()


func count_spells() -> void:
	request_count_spells.emit()


func fill_spells(count:int=0):
	var FillTweener = create_tween()
	FillTweener.tween_property(%Spells, "value", float(count), 1.0)


func fill_bars_non(fill_time:float, health:int):
	%Health.max_value = health
	
	var FillTweener = create_tween()
	FillTweener.tween_property(%Health, "value", float(health), fill_time)


func fill_bars_spell(fill_time:float, health:int, time:int):
	%Health.max_value = health
	%Time.max_value = time
	
	%SpellContainer.modulate.r = 1
	%SpellContainer.modulate.g = 1
	%SpellContainer.modulate.b = 1
	
	var FillTweener = create_tween().set_parallel(true)
	FillTweener.tween_property(%Health, "value", float(health), fill_time)
	FillTweener.tween_property(%Time, "value", float(time), fill_time)


func set_bars_timeout():
	%Timeout.show()
	%SpellContainer.modulate.r = 0
	%SpellContainer.modulate.g = 0


func update_health(health:int):
	%Health.value = health


func update_time(time:float):
	%Time.value = time


func reset_bars():
	%Health.value = 0
	%Time.value = 0
	%Timeout.hide()


func set_boss_name(boss_name:String):
	%BossName.text = boss_name


func boss_spell_activate(
		spell_name:String, 
		spell_portrait_data:SpellPortrait_Data=null,
		spell_portrait_base:PackedScene=null
	) -> void:
	
	%SpellName.text = spell_name
	%Spells.value -= 1
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(%SpellContainer, "position", SPELL_SHOW_POSITION, 0.8)
	tween.tween_property(%SpellContainer, "modulate:a", 1.0, 0.8)
	
	if spell_portrait_data != null:
		var spell_portrait = null
		if spell_portrait_base == null:
			spell_portrait = SPELL_PORTRAIT.instantiate()
		else:
			spell_portrait = spell_portrait_base.instantiate()
		
		spell_portrait.set_portrait(spell_portrait_data)
		
		GlobalStage.request_add_portrait.emit(spell_portrait)


func boss_spell_deactivate() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(%SpellContainer, "position", SPELL_HIDE_POSITION, 0.6)
	tween.tween_property(%SpellContainer, "modulate:a", 0, 0.6)


func add_spell_background(background:Background) -> void:
	GlobalStage.request_add_background.emit(background)


func calculate_bonus(base:int, extra:int):
	request_calculate_bonus.emit(base, extra)


func display_bonus(value:int=0) -> void:
	if value == 0:
		%Bonus.text = "Bonus Failed"
	else:
		%Bonus.text = "Bonus: " + str(value)
	
	%EventAnimator.play("Bonus")


func slow():
	GlobalStage.request_slow.emit()


func slow_stop():
	GlobalStage.request_slow_release.emit()


func stop():
	GlobalStage.request_stop.emit()


func release_stop():
	GlobalStage.request_stop_release.emit()


func shake(amplitude:float, time:float, hold:bool=false):
	GlobalStage.request_shake.emit(amplitude, time, hold)


func play_sound_boss(stream:AudioStreamWAV) -> void:
	%Sound.stream = stream
	%Sound.play()
