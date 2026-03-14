extends CanvasLayer

const LOADING_TEXTURE := preload("res://Master/Main/LoadingTexture.png")

const MAX := -1.8
const TIME := 0.5

signal load_in_done
signal load_out_done




func _ready():
	visible = false
	%LoadingAnimation.material.set_shader_parameter("x_displacement", 0.0)




func load_in() -> void:
	self.visible = true
	%LoadingAnimation.texture = get_viewport_texture()
	%LoadingStill.texture = LOADING_TEXTURE
	
	var LoadInTween = create_tween()
	LoadInTween.tween_property(%LoadingAnimation.material, "shader_parameter/x_displacement", MAX, TIME)
	LoadInTween.finished.connect(_on_Tweener_load_in_finished)


func load_out() -> void:
	%LoadingAnimation.texture = LOADING_TEXTURE
	%LoadingStill.texture = null
	
	var LoadOutTween = create_tween()
	LoadOutTween.tween_property(%LoadingAnimation.material, "shader_parameter/x_displacement", MAX, TIME)
	LoadOutTween.finished.connect(_on_Tweener_load_out_finished)




func get_viewport_texture() -> Texture2D:
	var texture:Image = get_viewport().get_texture().get_image()
	var image:ImageTexture = ImageTexture.create_from_image(texture)
	
	return image




func _on_Tweener_load_in_finished():
	%LoadingAnimation.texture = null
	%LoadingAnimation.material.set_shader_parameter("x_displacement", 0.0)
	
	load_in_done.emit()


func _on_Tweener_load_out_finished():
	%LoadingAnimation.texture = null
	%LoadingAnimation.material.set_shader_parameter("x_displacement", 0.0)
	self.visible = false
	
	load_out_done.emit()
