extends CanvasLayer

signal stage_in
signal stage_out




func _ready():
	self.visible = true
	%StageCover.modulate.a = 1




func stage_cover_in() -> void:
	%Animator.play("Stage_In")
	await %Animator.animation_finished
	stage_in.emit()


func stage_cover_out() -> void:
	%Animator.play("Stage_Out")
	await %Animator.animation_finished
	stage_out.emit()
