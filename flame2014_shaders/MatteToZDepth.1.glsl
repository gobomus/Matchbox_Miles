uniform float adsk_result_w, adsk_result_h;

void main() {
	vec2 coords	= gl_FragCoord.xy / vec2(adsk_result_w, adsk_result_h);

	vec4 gradient;
	float inv_y_coords	= 1.0 - coords.y;
	gradient	= vec4 (vec3(inv_y_coords), 1.0);

	gl_FragColor	= gradient;
}
