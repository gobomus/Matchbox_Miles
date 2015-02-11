//Idea from here: http://www.catalinzima.com/2008/01/converting-displacement-maps-into-normal-maps/

#version 120

#define INPUT Front
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform	float normalStrength;
uniform	float width;
uniform float sobel_width;
uniform int times;
uniform bool keep_between_0_and_1;
uniform bool invert_Y;
uniform bool invert_X;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec4 col = texture2D(INPUT, st);

	vec2 texelSize = 1.0 / res * .1;

	vec3 N = vec3(0.0);
	vec3 edge = vec3(0.0);

	for (int i = 1; i <= times; i++) {
 
    	vec3 tl = tex (INPUT, st + texelSize * vec2(-i, -i)).rgb;
    	vec3  l = tex (INPUT, st + texelSize * vec2(-i,  0)).rgb;
    	vec3 bl = tex (INPUT, st + texelSize * vec2(-i,  i)).rgb;
    	vec3  t = tex (INPUT, st + texelSize * vec2( 0, -i)).rgb;
    	vec3  b = tex (INPUT, st + texelSize * vec2( 0,  i)).rgb;
    	vec3 tr = tex (INPUT, st + texelSize * vec2( i, -i)).rgb;
    	vec3  r = tex (INPUT, st + texelSize * vec2( i,  0)).rgb;
    	vec3 br = tex (INPUT, st + texelSize * vec2( i,  i)).rgb;
 
    	vec3 tdX = (tr + r*sobel_width + br -tl - l*sobel_width - bl);
    	vec3 tdY = (bl + b*sobel_width + br -tl - t*sobel_width - tr);

		edge +=  sqrt(tdX * tdX + tdY * tdY);

		float dX = luma(tdX);
		float dY = luma(tdY);
 
    	// Build the normalized normal
    	N += vec3(normalize(vec3(dX, dY, 1.0 / normalStrength)));
	}

	N /= times;
	edge /=times;

    //convert (-1.0 , 1.0) to (0.0 , 1.0)
    N =  N * 0.5 + 0.5;

	if (invert_Y) {
		N.g = 1.0 - N.g;
	}

	if (invert_X) {
		N.r = 1.0 - N.r;
	}

	if (! keep_between_0_and_1) {
    	N =  (N - 0.5) * 2.0;
	}

	gl_FragColor = vec4(N, luma(edge));
}
