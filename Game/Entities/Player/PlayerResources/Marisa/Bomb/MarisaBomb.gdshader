shader_type canvas_item;

uniform float amplitude: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float displacement: hint_range(0.0, 100.0, 0.01) = 0.0;


void fragment() {
	float hue_map = ((UV.y + UV.x) / amplitude) + displacement;

	vec3 c = vec3(hue_map,1.0,1.0);
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	vec3 color_mod = c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);

	COLOR.rgb = color_mod;
}
