shader_type canvas_item;

uniform vec4 flash_color: source_color = vec4(1, 1, 1, 1);
uniform float flash_modifier: hint_range(0.0, 1.0, 0.1) = 0;
uniform bool flash_alpha = false;


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec3 adjust_color = mix(flash_color.rgb, vec3(1, 1, 1), flash_modifier);
	color.rgb = mix(color.rgb, adjust_color, flash_modifier);
	if (!flash_alpha) {
		color.a = (1.0-flash_modifier) * (1.0-flash_modifier) * color.a;
	}
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
