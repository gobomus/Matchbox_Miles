
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

// Texture input
uniform sampler2D Texture;
uniform float radius;

#define PI 3.14159265358979323846264338327


void main(void)
{

	
	// Normalised texture coords
	vec2 texCoord = gl_FragCoord.xy / res;
	vec2 st = texCoord;
	st = (st - .5) * 2.0;

	float a = atan(st.x, st.y);
	st = vec2(radius, a);


	gl_FragColor = texture2D(Texture, st);
}


