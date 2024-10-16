shader_type canvas_item;

uniform float amount = 40.0;

void fragment() {
	vec2 uv = UV*1000.0;
	float a = fract(sin(dot(UV, vec2(12.9898, 78.233) * TIME)) * 438.5453) * 1.9;
	vec4 col = texture(TEXTURE, UV);
	col.a *= pow(a, amount);
	COLOR.a = col.a * COLOR.a;
}