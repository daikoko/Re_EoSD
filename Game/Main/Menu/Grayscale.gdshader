shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float brightness: hint_range(0, 1) = 0.5;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	COLOR.rgb = vec3(dot(color.rgb, vec3(brightness, brightness, brightness)));
}
