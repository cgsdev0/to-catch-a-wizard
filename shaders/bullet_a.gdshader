shader_type canvas_item;

uniform vec4 color_1 = vec4(.0, .0, .0, 1.0);
uniform vec4 color_2 = vec4(0.5, 0.5, 0.5, 1.0);
void fragment() {
	vec4 col = vec4(0.9, 0.4, 0.0, 1.0);
	float a = texture(TEXTURE, UV).a;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0) + col;
	COLOR.a = round(a * 3.0) / 6.0;
	
}