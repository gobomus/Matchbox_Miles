#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform vec2 p1, p2;
uniform float width;
uniform vec2 mouse;
uniform float softness;

vec3 Line(vec2 p1,vec2 p2,float r,vec2 px)
{
	float c = 0.0;

	vec2 n = normalize((p2-p1).yx)*vec2(-1,1);	
	vec2 d = normalize((p2-p1));	

	c = 1.0 - abs( dot(n,px-p1) / r );

	c *= clamp( (dot(d,px-p1) * dot(-d,px-p2)) * 0.1 , 0.0, 1.0);
	c = clamp(c, 0.0, 1.0);	

	c = smoothstep(0.00, .2, c);

	return vec3(c);
}

void main( void ) {

	vec2 p = ( gl_FragCoord.xy - res / 2.);
	vec4 front = texture2D(Front, gl_FragCoord.xy/res);
	
	
	vec2 m = (mouse - 0.5) * res;
	vec2 m2 = (p2 - 0.5) * res;

	vec3 c = vec3(0.0);

	vec2 Point = vec2(m.x, m.y);
	vec2 Point2 = vec2(m2.x, m2.y);

	c += Line(m, m2, width+1.25, p);

	
	gl_FragColor = vec4(c,1.0);

}

