extends Resource 
class_name BulletData

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
	COLOR.RED:     Color(1,   0.5, 0.5, 1),
	COLOR.YELLOW:  Color(1,   1.5, 0.5, 1),
	COLOR.GREEN:   Color(0.5, 1,   0.5, 1),
	COLOR.CYAN:    Color(0.5, 1,   1,   1),
	COLOR.BLUE:    Color(0.5, 0.5, 1,   1),
	COLOR.MAGENTA: Color(1,   0.5, 1,   1),
	COLOR.WHITE:   Color(1,   1,   1,   1),
}

@export var texture:Texture2D
@export var shape:Shape2D

@export_group("Color")
@export var color_option:COLOR
@export var color_custom:Color

@export_group("Visibility")
@export var visibility:Rect2 = Rect2(-10, -10, 20, 20)

var color:Color : get=_get_color


func _get_color() -> Color:
	if color_option == COLOR.NULL:
		return color_custom
	else:
		return COLOR_DICT[color_option]
