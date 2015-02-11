/*
uniform variables are variables supplied by
the user via the UI
*/

//sampler2D is the type that represents a type of texure

uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;

/*
The following uniforms are provided by the autodesk api
there are many. These to represent the width and height of
the input
*/

uniform float adsk_result_w, adsk_result_h;

// These uniforms will show up in the user interface for the user to adjust
uniform float mmix;
uniform bool premult;


// Every shader needs at least a void main(void)
void main(void)
{
	// this is how you get your uv coords. You need some sort of UV's to load a texture
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	// Load in the inputs
	vec3 front = texture2D(Front, st).rgb;
	vec3 back = texture2D(Back, st).rgb;
	float matte = clamp(texture2D(Matte, st), 0.0, 1.0).r;

	// clamp your matte
	matte = clamp(matte, 0.0, 1.0);


	// check to see if the user defined the front input as being premultiplied
	if (premult) {
		// if so divide front by matte
		front = front / (matte + .00001);
	}

	// set the alpha to be some mix of the matte input and black (Mix the front down) if wanted
	float alpha = mix(matte, 0.0, mmix);

	// comp the front over the back using the alpha
	vec3 col = mix(back, front, alpha);


	// send the result to the screen. Yay
	gl_FragColor.rgb = col;
}
