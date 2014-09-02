#version 120

// This code is taken directly from Kyle Obley's K_BlurMask v1.1 shader
//

uniform sampler2D adsk_results_pass5;
uniform float adsk_result_w, adsk_result_h, edge_blur;
const float pi = 3.141592653589793238462643383279502884197969;
uniform float edge_strength;

void main() {
	vec2 xy = gl_FragCoord.xy;
	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);
	float v_bias = 1.0;
	float es = 1.0 + edge_strength;

	float v_sigma1 = edge_blur * v_bias;
	
	int support = int(v_sigma1 * 3.0);

	// Incremental coefficient calculation setup as per GPU Gems 3
	vec3 g;
	g.x = 1.0 / (sqrt(2.0 * pi) * v_sigma1);
	g.y = exp(-0.5 / (v_sigma1 * v_sigma1));
	g.z = g.y * g.y;

	if(v_sigma1 == 0.0) {
		g.x = 1.0;
	}

	// Centre sample
	vec4 a = g.x * texture2D(adsk_results_pass5, xy * px);
	float energy = g.x;
	g.xy *= g.yz;

	// The rest
	for(int i = 1; i <= support; i++) {
		a += g.x * texture2D(adsk_results_pass5, (xy - vec2(0.0, float(i))) * px);
		a += g.x * texture2D(adsk_results_pass5, (xy + vec2(0.0, float(i))) * px);
		energy += 2.0 * g.x;
		g.xy *= g.yz;
	}
	a /= energy;

	vec4  edge = a*es;
	edge = clamp(edge, 0.0, 1.0);

	gl_FragColor = edge;
}
