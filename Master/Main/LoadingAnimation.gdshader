shader_type canvas_item;

uniform float x_displacement : hint_range(-2, 0) = 0;

uniform float y_step : hint_range(0, 1) = 0.2;
uniform float lag_value : hint_range(0, 1) = 0.2;


void fragment() {
	vec2 uv_displaced = UV;
	float lag_bin = floor(UV.y / y_step);

	uv_displaced.x -= clamp(x_displacement + (lag_bin * lag_value), 0.0, x_displacement);
	if (uv_displaced.x >= 0.0 && uv_displaced.x <= 1.0) {
		COLOR = texture(TEXTURE, uv_displaced);
	}
	else {
		COLOR.a = 0.0;
	}
}
