#version 120

#define INPUT Front
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform vec3 color;
uniform float d;
uniform vec2 light;


void main() {
	vec2 st = gl_FragCoord.xy / res;
	vec2 delta = vec2(d);
  	float brightness =
    (
      texture2D(INPUT, st + delta * (light * .5)).r -
      texture2D(INPUT, st - delta * (light * .5)).r
    ) / (2 * d);

	brightness = 1.0 - brightness;
  gl_FragColor = vec4(color * brightness, 1.0);

}

