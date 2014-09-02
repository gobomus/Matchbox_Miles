// This shaders was copied more or less line for line from Ls_Ash.1.glsl

// Pass 1: edge detection
// lewis@lewissaunders.com

uniform sampler2D adsk_results_pass3;
uniform float adsk_result_w, adsk_result_h;
uniform float edge_size;

void main() {
	vec2 xy = gl_FragCoord.xy;
	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);

	float threshold = .5;


	// Find gradients of adsk_results_pass3 with X/Y Sobel convolution
	vec2 d;
	d.x  =  1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(-1.0, -1.0)) * px).g;
	d.x +=  2.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(-1.0,  0.0)) * px).g;
	d.x +=  1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(-1.0, +1.0)) * px).g;
	d.x += -1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(+1.0, -1.0)) * px).g;
	d.x += -2.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(+1.0,  0.0)) * px).g;
	d.x += -1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(+1.0, +1.0)) * px).g;
	d.y  =  1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(-1.0, -1.0)) * px).g;
	d.y +=  2.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2( 0.0, -1.0)) * px).g;
	d.y +=  1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(+1.0, -1.0)) * px).g;
	d.y += -1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(-1.0, +1.0)) * px).g;
	d.y += -2.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2( 0.0, +1.0)) * px).g;
	d.y += -1.0 * texture2D(adsk_results_pass3, (xy + edge_size * vec2(+1.0, +1.0)) * px).g;

	// Magnitude of gradients finds edges
	float mag = length(d);
	float edginess = mag;

	// Threshold removes minor edges
	edginess *= 1.0 - threshold;
	edginess -= threshold;

	gl_FragColor = vec4(edginess);
}
