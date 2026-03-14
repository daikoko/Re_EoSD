shader_type canvas_item;

uniform float modifier:hint_range(0.0, 1000.0, 0.1);
uniform bool invert = false;


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (modifier < 1000.0) {
		if (invert) {
			color.a = mix(color.a, 0.0, (2.0 - (UV.x + UV.y)) / modifier);
		}
		else {
			color.a = mix(color.a, 0.0, ((UV.x + UV.y)) / modifier);
		}
	}

	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
