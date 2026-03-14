shader_type canvas_item;

uniform float distortion_intensity : hint_range(0, 10) = 0;
uniform float distortion_alpha : hint_range(0, 1) = 1;
uniform sampler2D noise;

void fragment() {
	vec2 base_uv = UV;
	float noise_text = texture(noise, UV).r - 0.5;

	vec2 distortion_uv = base_uv + (noise_text * distortion_intensity);

	COLOR = texture(TEXTURE, distortion_uv);
	COLOR.a = COLOR.a * distortion_alpha;
}
