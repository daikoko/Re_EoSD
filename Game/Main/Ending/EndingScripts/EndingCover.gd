extends CanvasLayer

signal screen_in
signal screen_out


func _ready():
	self.visible = true
	%Cover.modulate.a = 0




func screen_cover_in() -> void:
	%Animator.play("Cover_In")
	await %Animator.animation_finished
	screen_in.emit()


func screen_cover_out() -> void:
	%Animator.play("Cover_Out")
	await %Animator.animation_finished
	screen_out.emit()
