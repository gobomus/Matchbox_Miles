#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform vec2 shear;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 center = vec2(.5);

	mat2 x = mat2(0,1,1,0);
	mat2 t = mat2(0, -shear.x, shear.y, 0);

	//-1,-1 is a flip
	// 0,-1 is a flip flop
	// 1, 1 is flop

	st *= x * t;
	

	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front, 0.0);
}
