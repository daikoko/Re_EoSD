extends Node2D

var id:int




func _ready() -> void:
	set_process(false)


func _process(_delta):
	if GlobalStage.is_current_stage_clear_plain():
		deactivate()




func activate_clear(position:Vector2) -> void:
	self.position = position
	self.modulate = Color(1, 1, 1, 1)
	self.visible = true
	set_process(true)
	
	%Clear.restart()
	await %Clear.finished
	
	deactivate()


func activate_bomb(position:Vector2, color:Color) -> void:
	self.position = position
	self.modulate = color
	self.visible = true
	set_process(true)
	
	%Bomb.restart()
	await %Bomb.finished
	
	deactivate()


func deactivate() -> void:
	if not is_processing():
		return
	
	self.visible = false
	set_process(false)
	
	GlobalPool.particle_despawned.emit(id)
