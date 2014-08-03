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

uniform	float normalStrength;
uniform	float width;
uniform float sobel_width;
uniform int times;

uniform vec3 color;
uniform vec2 delta;
uniform vec2 light;


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec2 size = vec2(8.0, 0.0);
	vec3 off = vec3(texel.x, 0, texel.y);

	vec4 col = texture2D(INPUT, st);

	float s11 = col.x;
	float s01 = tex(INPUT, st + off.xy).x;
	float s21 = tex(INPUT, st + off.zy).x;
	float s10 = tex(INPUT, st + off.yx).x;
	float s12 = tex(INPUT, st + off.yz).x;

	vec3 va = normalize(vec3(size.xy, s21 - s01));
	vec3 vb = normalize(vec3(size.yx, s12 - s10));

	vec4 bump = vec4(cross(va,vb), s11);

	gl_FragColor = bump;


	vec2 texelSize = 1.0 / res;

	vec4 N = vec4(0.0);
	vec2 Q = vec2(0.0);

	for (int i = 1; i <= times; i++) {
 
    	float tl = abs(tex (INPUT, st + texelSize * vec2(-i, -i)).x);   // top left
    	float  l = abs(tex (INPUT, st + texelSize * vec2(-i,  0)).x);   // left
    	float bl = abs(tex (INPUT, st + texelSize * vec2(-i,  i)).x);   // bottom left
    	float  t = abs(tex (INPUT, st + texelSize * vec2( 0, -i)).x);   // top
    	float  b = abs(tex (INPUT, st + texelSize * vec2( 0,  i)).x);   // bottom
    	float tr = abs(tex (INPUT, st + texelSize * vec2( i, -i)).x);   // top right
    	float  r = abs(tex (INPUT, st + texelSize * vec2( i,  0)).x);   // right
    	float br = abs(tex (INPUT, st + texelSize * vec2( i,  i)).x);   // bottom right
 
    // Compute dx using Sobel:
    //           -1 0 1 
    //           -2 0 2
    //           -1 0 1
    	float dX = tr + sobel_width*r + br -tl - sobel_width*l - bl;
 
    // Compute dy using Sobel:
    //           -1 -2 -1 
    //            0  0  0
    //            1  2  1
    	float dY = bl + sobel_width*b + br -tl - sobel_width*t - tr;

 
    	// Build the normalized normal
    	N += vec4(normalize(vec3(dX, 1.0f / normalStrength, dY)), 1.0f);
		Q += vec2(dX, dY);

	}

	N /= times;
	Q /= times;

	vec2 gradient = Q;
    float brightness = dot(gradient, light);

	vec3 tmp = color * (1.0 - brightness);

    gl_FragColor = vec4(tmp + col.rgb, 1.0);

 
 
    //convert (-1.0 , 1.0) to (0.0 , 1.0), if needed
    N =  N * 0.5 + 0.5;

	float g = N.g;
	N.g = N.b;
	N.b = g;
	gl_FragColor = N;
}
