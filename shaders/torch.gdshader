shader_type canvas_item;

uniform vec2 position;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 3758.5453);
}

void fragment() {
	vec4 a = texture(TEXTURE, UV);
	vec4 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, a.a);
	float seed = rand(position);
	float seed2 = rand(UV);
	COLOR = screen + vec4(0.15, 0.05 + 0.02 * sin((TIME + seed) * 4.0 * (seed + 1.0)), 0.0, 2.0);
	COLOR.a = a.a;
//	if(a.a > 0.0) {
//		COLOR.a += sin(seed2 / 2.0 + TIME);
//	}
}
