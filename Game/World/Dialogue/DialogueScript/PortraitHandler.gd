extends CanvasLayer

const PORTRAIT := preload("res://Game/World/Dialogue/DialogueScript/DialoguePortrait.tscn")
const PORTRAIT_PATH := "res://Game/World/Dialogue/DialogueResources/DialogueSprite_"

var sprite_dict:Dictionary = {}




func sprite_enter(identity:String, configuration:String) -> void:
	if sprite_dict.has(identity):
		return
	
	var new_portrait = PORTRAIT.instantiate()
	self.add_child(new_portrait)
	
	new_portrait.activate(identity, configuration)
	sprite_dict[identity] = new_portrait


func sprite_exit(identity:String) -> void:
	if !sprite_dict.has(identity):
		return
	
	var portrait = sprite_dict[identity]
	portrait.deactivate()
	
	sprite_dict.erase(identity)


func new_expression(identity:String, expression:String, quick:bool) -> void:
	if !sprite_dict.has(identity):
		return
	
	var portrait = sprite_dict[identity]
	var texture
	if expression != "":
		texture = load(PORTRAIT_PATH + expression + ".png")
	else:
		texture = null
	
	portrait.change_expression(expression, texture)
	portrait.change_layer_top()
	portrait.focus(quick)
	
	for key in sprite_dict.keys():
		if key == identity:
			continue
		
		var other_portrait = sprite_dict[key]
		other_portrait.change_layer_push()
		other_portrait.unfocus(quick)


func unfocus_all() -> void:
	for key in sprite_dict.keys():
		var portrait = sprite_dict[key]
		portrait.unfocus(false)


func deactivate_all() -> void:
	for key in sprite_dict.keys():
		var portrait = sprite_dict[key]
		portrait.deactivate()
	
	sprite_dict.clear()


func remove_all() -> void:
	for child in self.get_children():
		child.queue_free()
