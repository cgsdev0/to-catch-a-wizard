shader_type canvas_item;

void fragment() {
	vec4 col = vec4(1.5, 1.1, 0.0, 1.0) * 2.0;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0) + col;
	COLOR.a = texture(TEXTURE, UV).a / 2.0; //read from texture
}