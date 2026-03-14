extends CanvasLayer

var active:bool

signal credits_finished


func _ready():
	visible = false


func _input(event: InputEvent) -> void:
	if not active:
		return
	
	if event.is_action_pressed("dialogue_skip"):
		credits_finished.emit()
		%Animator.stop()


func start() -> void:
	visible = true
	
	await get_tree().process_frame
	
	if GlobalStage.current_section == GlobalSettings.SECTION.EXTRA:
		credits_finished.emit()
		return
	if GlobalStage.current_section == GlobalSettings.SECTION.PHANTASM:
		credits_finished.emit()
		return
	if GlobalStage.current_section == GlobalSettings.SECTION.PRACTICE:
		credits_finished.emit()
		return
	
	await self.create_tween().tween_interval(2.0).finished
	
	active = true
	
	GlobalStage.request_music_stop.emit()
	%Music.play()
	
	%Animator.play("Credits")
	await %Animator.animation_finished
	
	credits_finished.emit()
