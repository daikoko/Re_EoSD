extends Sprite2D

enum MODE {
	INACTIVE,
	UNFOCUSED,
	FOCUSED
}

const POSITION_CONFIGURATION_DICT = {
	"left": {
		"inactive":  Vector2(-500, 550),
		"unfocused": Vector2(70, 550),
		"focused":   Vector2(120, 550)
		},
	"right": {
		"inactive":  Vector2(1180, 550),
		"unfocused": Vector2(610, 550),
		"focused":   Vector2(560, 550)
		},
	"center": {
		"inactive":  Vector2(340, 1390),
		"unfocused": Vector2(340, 700),
		"focused":   Vector2(340, 650)
		}
}

const TIME_NORMAL :=     0.2
const TIME_QUICK :=      0.05
const TIME_ACTIVATE :=   0.4
const TIME_DEACTIVATE := 0.1

const MODULATE_INACTIVE :=  Color(0, 0, 0, 1)
const MODULATE_UNFOCUSED := Color(0.5, 0.5, 0.5, 1)
const MODULATE_FOCUSED :=   Color(1, 1, 1, 1)

var position_inactive:Vector2
var position_unfocused:Vector2
var position_focused:Vector2

var identity:String
var expression:String

var mode:int = 0
var MoveTween:Tween
# Fix these tweens




func activate(identity:String, configuration:String) -> void:
	self.mode = MODE.INACTIVE
	
	self.identity =           identity
	self.position_inactive =  POSITION_CONFIGURATION_DICT[configuration]["inactive"]
	self.position_unfocused = POSITION_CONFIGURATION_DICT[configuration]["unfocused"]
	self.position_focused =   POSITION_CONFIGURATION_DICT[configuration]["focused"]
	
	self.modulate = MODULATE_INACTIVE
	self.position = position_inactive


func deactivate() -> void:
	self.mode = MODE.INACTIVE
	
	create_move_tween(position_inactive, MODULATE_INACTIVE, TIME_DEACTIVATE)


func focus(quick:bool) -> void:
	if mode == MODE.INACTIVE:
		create_move_tween(position_focused, MODULATE_FOCUSED, TIME_ACTIVATE)
	else:
		if quick:
			create_move_tween(position_focused, MODULATE_FOCUSED, TIME_QUICK)
		else:
			create_move_tween(position_focused, MODULATE_FOCUSED, TIME_NORMAL)
	
	mode = MODE.FOCUSED


func unfocus(quick:bool) -> void:
	mode = MODE.UNFOCUSED
	
	if quick:
		create_move_tween(position_unfocused, MODULATE_UNFOCUSED, TIME_QUICK)
	else:
		create_move_tween(position_unfocused, MODULATE_UNFOCUSED, TIME_NORMAL)


func change_expression(expression:String, texture:Texture) -> void:
	self.expression = expression
	self.texture = texture


func change_layer_top() -> void:
	z_index = 0


func change_layer_push() -> void:
	z_index -= 1




func create_move_tween(position:Vector2, modulate:Color, time:float) -> void:
	if MoveTween:
		MoveTween.kill()
	
	MoveTween = self.create_tween().set_parallel(true)
	MoveTween.tween_property(self, "position", position, time)
	MoveTween.tween_property(self, "modulate", modulate, time)
