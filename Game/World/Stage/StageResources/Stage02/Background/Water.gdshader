shader_type spatial;

uniform sampler2D texturemap;
uniform vec2 size = vec2(1.0, 1.0);
uniform vec2 amplitude = vec2(1.0, 1.0);
uniform vec2 frequency = vec2(1.0, 1.0);
uniform vec2 time_factor = vec2(1.0, 1.0);

uniform sampler2D offsetmap : hint_default_black;
uniform float offset_timescale = 0.01;
uniform float offset_amplitude = 0.01;



float height (vec2 pos) {
	float value_x = TAU * (pos.x / size.x);
	float value_z = TAU * (pos.y / size.y);

	float time_x = TIME * time_factor.x;
	float time_z = TIME * time_factor.y;

	return (amplitude.x * sin(frequency.x * value_x + time_x)) + (amplitude.y * sin(frequency.y * value_z + time_z));
}

void vertex() {
	VERTEX.y += height(VERTEX.xz);

	TANGENT = normalize(vec3(0.0, height(VERTEX.xz + vec2(0.0, 0.2)) - height(VERTEX.xz + vec2(0.0, -0.2)), 0.4));
	BINORMAL = normalize(vec3(0.4, height(VERTEX.xz + vec2(0.2, 0.0)) - height(VERTEX.xz + vec2(-0.2, 0.0)), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment() {
	vec2 base_offset = UV + (TIME * offset_timescale);
	vec2 texture_offset = (texture(offsetmap, base_offset).gr * 2.0) - 1.0;
	vec2 texture_uv = UV + (offset_amplitude * texture_offset);
	ALBEDO = texture(texturemap, texture_uv).rgb;
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
