extends Resource
class_name LaserData

enum COLOR {
	NULL,
	RED,
	YELLOW,
	GREEN,
	CYAN,
	BLUE,
	MAGENTA,
	WHITE
}

const COLOR_DICT = {
	COLOR.RED:     Color(1, 0, 0, 1),
	COLOR.YELLOW:  Color(1, 1, 0, 1),
	COLOR.GREEN:   Color(0, 1, 0, 1),
	COLOR.CYAN:    Color(0, 1, 1, 1),
	COLOR.BLUE:    Color(0, 0, 1, 1),
	COLOR.MAGENTA: Color(1, 0, 1, 1),
	COLOR.WHITE:   Color(1, 1, 1, 1),
}

@export var color_option:COLOR
@export var color_custom:Color
@export var weight:float = 1

var color:Color : get=_get_color




func _init(weight:float=1, color_option:int=0, color_custom:Color=Color(1,1,1,1)):
	self.color_option = color_option as COLOR
	self.color_custom = color_custom
	self.weight = weight




func _get_color() -> Color:
	if color_option == COLOR.NULL:
		return color_custom
	else:
		return COLOR_DICT[color_option]
