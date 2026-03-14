shader_type canvas_item;

uniform vec4 base_color: source_color = vec4(1, 1, 1, 1);
uniform float base_modifier: hint_range(0.0, 1.0, 0.1) = 0;
uniform vec4 flash_color: source_color = vec4(1, 1, 1, 1);
uniform float flash_modifier: hint_range(0.0, 1.0, 0.1) = 0;

uniform bool colorize;
uniform bool hide;


vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	if (colorize) {
		float hue = rgb2hsv(base_color.rgb).x;
		float sat = rgb2hsv(color.rgb).y;
		float val = rgb2hsv(color.rgb).z;
		
		color.rgb = hsv2rgb(vec3(hue,sat,val));
		color.rgb = mix(color.rgb, base_color.rgb, base_modifier);
		color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);
	}
	else {
		color.rgb = mix(color.rgb,     flash_color.rgb, flash_modifier);
	}
	
	if (hide) {
		COLOR = vec4(1,1,1,0);
	}
	else {
		COLOR = color;
	}
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
