uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D from;
uniform sampler2D to;
uniform float progress;
 
uniform float reflection;
uniform float perspective;
uniform float depth;
//float depth = 1.0 - perspective * .5;
 
const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
const vec2 boundMin = vec2(0.0, 0.0);
const vec2 boundMax = vec2(1.0, 1.0);

uniform vec2 t;
 
bool inBounds (vec2 p) {
  return all(lessThan(boundMin, p)) && all(lessThan(p, boundMax));
}
 
vec2 project (vec2 p) {
  return p * vec2(1.0, -1.2) + vec2(0.0, -0.02);
}
 
vec4 bgColor (vec2 p, vec2 pfr, vec2 pto) {
  vec4 c = black;
  pfr = project(pfr);
  if (inBounds(pfr)) {
    c += mix(black, texture2D(from, pfr), reflection * mix(1.0, 0.0, pfr.y));
  }

  return c;
}
 
void main() {
  	vec2 st = gl_FragCoord.xy / res;
 
  	vec2 pfr, pto = vec2(-1.);
 
  	float size = mix(1.0, depth, progress);

  	float persp = perspective * progress;

  	//float persp = perspective;

  	//pfr = (st - vec2(.5)) * vec2(size/(1.0-perspective*progress), size/(1.0-size*persp*st.x)) + vec2(0.5);
	//pfr = (st - vec2(.5)) * vec2(size / (1.0 - perspective), size / (1.0 - size * persp * st.x)) + vec2(.5);

	//vec2 pfr = (st - vec2(.5)) * vec2(depth / (1.0 - perspective), depth / (1.0 - persp * st.x)) + vec2(.5);

 
 
	gl_FragColor = black;

   	if (inBounds(pfr)) {
      	gl_FragColor = texture2D(from, pfr);
	}
}
