shader_type canvas_item;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 3758.5453);
}

void fragment() {
float iGlobalTime = TIME;
vec2 fragCoord = SCREEN_UV;
vec4 texColor = vec4(0);

// get position to sample
vec2 samplePosition = SCREEN_UV;
float whiteNoise = 9999.0;

// Jitter each line left and right
samplePosition.x = samplePosition.x+(rand(vec2(iGlobalTime,fragCoord.y))-0.5)/180.0;
// Jitter the whole picture up and down
samplePosition.y = samplePosition.y+(rand(vec2(iGlobalTime))-0.5)/2048.0;
// Slightly add color noise to each line
texColor = texColor + (vec4(-0.5)+vec4(rand(vec2(fragCoord.y,iGlobalTime)),rand(vec2(fragCoord.y,iGlobalTime+1.0)),rand(vec2(fragCoord.y,iGlobalTime+2.0)),0))*0.1;

// Either sample the texture, or just make the pixel white (to get the staticy-bit at the bottom)
whiteNoise = rand(vec2(floor(samplePosition.y*80.0),floor(samplePosition.x*50.0))+vec2(iGlobalTime,0));
if (whiteNoise > 5.5-26.0*samplePosition.y || whiteNoise < 1.3-5.0*samplePosition.y) {
// Sample the texture.
// samplePosition.y = 1.0-samplePosition.y; //Fix for upside-down texture
 texColor = texColor + vec4(textureLod(SCREEN_TEXTURE, samplePosition, 0.0).rgb,1);
}
else {
 // Use white. (I'm adding here so the color noise still applies)
texColor = texColor + vec4(textureLod(SCREEN_TEXTURE, samplePosition, 0.0).rgb + vec3(0.5, 0.5, 0.5),1);
}
COLOR = texColor + vec4(0.25, 0.1, 0.4, 1.0);
}