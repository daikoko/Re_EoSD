shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	COLOR =  textureLod(TEXTURE, UV, blur_amount);
}