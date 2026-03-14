extends CanvasLayer




func _ready():
	self.visible = true




func change_scene(scene:Texture) -> void:
	%Scene.texture = scene
