#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);


uniform sampler2D Front;
uniform sampler2D Matte;

uniform bool flip, flop;

vec2 flipflop(vec2 coords) {
	mat2 x = mat2(0,1,1,0);
	mat2 t = mat2(0, 1, 1, 0);

	if (flip) {
		t = mat2(0, -1, 1, 0);
		coords *= t * x;
	}
	
	if (flop) {
		t = mat2(0, -1, 1, 0);
		coords *=  x * t;
	}

	return coords;
}


void main(void)
{
    vec2 st = gl_FragCoord.xy / res;

	vec3 front = vec3(0.0);
	float matte = 0.0;

	st = flipflop(st);

   	front = texture2D(Front, st).rgb;
   	matte = texture2D(Matte, st).r;


    gl_FragColor = vec4(front, matte);
}
