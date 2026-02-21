shader_type canvas_item;

uniform float fade_start : hint_range(0.0, 1.0) = 0.35;
uniform float fade_end : hint_range(0.0, 1.0) = 0.85;
uniform vec4 dark_color : source_color = vec4(0.04, 0.04, 0.07, 1.0);

void fragment() {
	float t = smoothstep(fade_start, fade_end, UV.y);
	COLOR = vec4(dark_color.rgb, t * dark_color.a);
}
