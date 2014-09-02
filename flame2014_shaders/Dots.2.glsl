#define pi 3.141592653589793238462643383279
uniform float blur_amount, adsk_result_w, adsk_result_h ;
uniform vec3 bg_color;
uniform int gridSize;
uniform sampler2D adsk_results_pass1;
uniform bool soften;

//Parameters for the blur
//These are values that provided the best results in the widest range of cases
//These are hard set to simplify the usage of the tool
float gamma     = 0.9;
int insamples   = 32;
int samples     = 36;


//A blur that samples elliptical rings around the pixel
//'samples'     : Sets the amount of samples around the ellipse
//'insamples'   : Sets the amount of rings to sample
//'blur_size'        : Sets the distance of the samples
//'gamma'       : Sets the gamma of weight of samples, along the distance
vec4 simple_blur2 (in sampler2D tex,
                        int samples,
                        int insamples,
                        float blur_size,
                        float gamma,
                        float image_width,
                        float image_height ) {

        vec2 coords = gl_FragCoord.xy / vec2( image_width, image_height );
        vec2 b_size	= vec2(blur_size) / vec2(image_width, image_height);

        //Have a minimal value for the gamma
        if (gamma < 0.01) { gamma = 0.01; };


        vec4 color = texture2D(tex, coords);
        float accum = 1.0;

        for (int i=0; i<samples; i++) {
                float a = (360.0 / float(samples)) * float(i);                //Define the angle of the sample
                a       = a * ( pi / 180.0 );                                 //Convert degrees to radians
		
                for (int p=0; p<insamples; p++) {
                        float rx = (b_size.x / float(insamples)) * float(p);  //Set the radius/distance of the sample
                        float ry = (b_size.y / float(insamples)) * float(p);  //Set the radius/distance of the sample
                        float sample_x = coords.x + rx * cos(a);
                        float sample_y = coords.y + ry * sin(a);
                        vec2 sample_coords = vec2(sample_x,sample_y);
                        float dist = distance(coords,sample_coords);
                        color += texture2D(tex, sample_coords) * dist;
                        accum += dist;
                }
        }

        color.rgb /= accum;
	color.a		= color.a > 1.0 ? 1.0 : color.a;
        return color;
}


void main() {

	vec2 coords	= gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec4 image	= texture2D(adsk_results_pass1, coords);
	vec4 bg		= vec4(bg_color, 0.0);

	if ( soften ) {
		float fg_matte  =  simple_blur2(adsk_results_pass1, samples, insamples, blur_amount, gamma, adsk_result_w, adsk_result_h ).a;
		image.rgb	= (bg.rgb * ( vec3(1.0) - vec3(fg_matte) ) ) + ( image.rgb * vec3(fg_matte) );
		image.a		= fg_matte;
	}


	gl_FragColor	= image;
}
