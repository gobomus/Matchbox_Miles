#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
uniform sampler2D adsk_results_pass1;

uniform sampler2D Front;

uniform vec2 position;
uniform float scale;
uniform float rotation;

uniform float radius;
uniform float falloff;

uniform bool repeat_texture;

bool isInTex( const vec2 coords )
{
	return coords.x >= 0.0 && coords.x <= 1.0 &&
			coords.y >= 0.0 && coords.y <= 1.0;
}

vec2 translate(vec2 st, vec2 center, vec2 position)
{
	//uncomment following if you want to link to tracker
	//vec2 off = position / vec2(adsk_result_w, adsk_result_h);
	//return (st - off);

	//comment following if you want to link to tracker
	return (st - position) + center;

}

vec2 uniform_scale(vec2 st, vec2 center, float scale) 
{
	vec2 ss = vec2(scale / vec2(100.0));

	return (st - center) / ss + center;
}

vec2 rotate(vec2 coords, vec2 center, float rotation)
{
	mat2 rotationMatrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );

   	coords -= center;
   	coords.x *= adsk_result_frameratio;
   	coords *= rotationMatrice;
   	coords.x /= adsk_result_frameratio;
   	coords += center;

	return coords;
}

float make_circle(vec2 st, vec2 center, float radius)
{
	st.x *= adsk_result_frameratio;
	center.x *= adsk_result_frameratio;

	float dist = length(st - center);

	center.x /= adsk_result_frameratio;
	st.x /= adsk_result_frameratio;

    float circle = clamp(radius - dist, 0.0, 1.0);

    circle = smoothstep(0.0, falloff, circle);

	return circle;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = vec4(0.0);
	vec2 center = vec2(.5);

	st = translate(st, center, position);
	st = uniform_scale(st, center, scale);
	st = rotate(st, center, rotation);

	if (! repeat_texture) {
		if ( isInTex(st) ) {
			front = texture2D(Front, st);
			front.a = make_circle(st, center, radius);
		}
	} else {
		front = texture2D(Front, st);
		front.a = make_circle(st, center, radius);
	}

	gl_FragColor = front;
}
