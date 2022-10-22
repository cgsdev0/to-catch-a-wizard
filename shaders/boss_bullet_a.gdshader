shader_type canvas_item;

void fragment() {
	vec4 col = vec4(0.0, 0.4, 0.0, 1.0);
	float a = texture(TEXTURE, UV).a;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0) + col;
	COLOR.a = round(a * 3.0) / 6.0;
	
}