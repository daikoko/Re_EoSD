extends Node2D

const ROT_SPEED_NORMAL := 40
const ROT_SPEED_FOCUS  := 90

var rot_speed:float




func _ready():
	toggle_focus(false)


func _input(event):
	if event.is_action_pressed("game_shift"):
		toggle_focus(true)
	if event.is_action_released("game_shift"):
		toggle_focus(false)


func _process(delta):
	%HitMarker.rotation += rot_speed * delta




func set_player_collider(
	hitbox:int, charge:int, collection:int, 
	inner:Texture2D, outer:Texture2D
	) -> void:
	
	var hitbox_shape = CircleShape2D.new()
	hitbox_shape.radius = hitbox
	%PlayerHitbox.set_shape(hitbox_shape)
	
	var chargebox_shape = CircleShape2D.new()
	chargebox_shape.radius = charge
	%PlayerGraze.set_shape(chargebox_shape)
	
	var collection_shape = CircleShape2D.new()
	collection_shape.radius = collection
	%PlayerCollection.set_shape(collection_shape)
	
	%Inner.texture = inner
	%Outer.texture = outer


func enable_hit() -> void:
	%PlayerHitbox.enable()
	%PlayerGraze.enable()


func disable_hit() -> void:
	%PlayerHitbox.disable()
	%PlayerGraze.disable()


func enable_item() -> void:
	%PlayerItem.enable()
	%PlayerCollection.enable()


func disable_item() -> void:
	%PlayerItem.disable()
	%PlayerCollection.disable()


func toggle_focus(enable:bool) -> void:
	if enable:
		%Inner.modulate.a = 1
		%Outer.modulate.a = 0.8
		%Outer.scale = Vector2(1, 1) * 0.8
		rot_speed = deg_to_rad(ROT_SPEED_FOCUS)
	else:
		%Inner.modulate.a = 0
		%Outer.modulate.a = 0.4
		%Outer.scale = Vector2(1, 1) * 1
		rot_speed = deg_to_rad(ROT_SPEED_NORMAL)
