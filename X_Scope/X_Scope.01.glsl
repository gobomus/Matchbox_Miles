#version 120

#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D Front;
uniform float adsk_result_w, adsk_result_h;

vec2 res = vec2(adsk_result_w, adsk_result_h);


uniform float p;


bool isInTex( const vec2 coords )
{
   return coords.x >= 0.0 && coords.x <= 1.0 &&
          coords.y >= 0.0 && coords.y <= 1.0;
}



void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 col = vec3(0.0);
	float third = st.x / .33333;

	vec2 rc = vec2(third, st.y);

	if (isInTex(rc)) {
		col.r = texture2D(Front, rc).r;
	}

	vec2 gc = st;
	gc.x -= .33333;
	gc.x /= .33333;
	
	if (isInTex(gc)) {
		col.g = texture2D(Front, gc).g;
	}

	vec2 bc = st;
	bc.x -= (.33333 * 2.0);
	bc.x /= .33333;
	
	if (isInTex(bc)) {
		col.b = texture2D(Front, bc).b;
	}


	gl_FragColor.rgb = col;
}
