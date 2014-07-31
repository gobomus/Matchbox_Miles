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
 
    float tl = abs(tex (INPUT, st + texelSize * vec2(-width, -width)).x);   // top left
    float  l = abs(tex (INPUT, st + texelSize * vec2(-width,  0)).x);   // left
    float bl = abs(tex (INPUT, st + texelSize * vec2(-width,  width)).x);   // bottom left
    float  t = abs(tex (INPUT, st + texelSize * vec2( 0, -width)).x);   // top
    float  b = abs(tex (INPUT, st + texelSize * vec2( 0,  width)).x);   // bottom
    float tr = abs(tex (INPUT, st + texelSize * vec2( width, -width)).x);   // top right
    float  r = abs(tex (INPUT, st + texelSize * vec2( width,  0)).x);   // right
    float br = abs(tex (INPUT, st + texelSize * vec2( width,  width)).x);   // bottom right
 
    // Compute dx using Sobel:
    //           -1 0 1 
    //           -2 0 2
    //           -1 0 1
    float dX = tr + 2*r + br -tl - 2*l - bl;
 
    // Compute dy using Sobel:
    //           -1 -2 -1 
    //            0  0  0
    //            1  2  1
    float dY = bl + 2*b + br -tl - 2*t - tr;

 
    // Build the normalized normal
    vec4 N = vec4(normalize(vec3(dX, 1.0f / normalStrength, dY)), 1.0f);
 
    //convert (-1.0 , 1.0) to (0.0 , 1.0), if needed
    N =  N * 0.5f + 0.5f;

	float g = N.g;
	N.g = N.b;
	N.b = g;
	gl_FragColor = N;


	//gl_FragColor = vec4(normalize(col * 2.0 - 1.0), 0.0);
}
