uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;
uniform float bias;
uniform float angle;

void main()
{
	float offset=0.5; // color offset
	float theta=radians(angle); // camera dependent angle vec2 ePerp=vec2(cos(angle),sin(angle));
	vec2 ePerp=vec2(cos(theta),sin(theta));
	vec2 st = gl_FragCoord.xy / res;

	vec3 color=texture2D(Front, st).rgb;

	color=pow(color,vec3(2.2));
	color+=vec3(0.001,0.001,0.001);

	float gm=pow(color[0]*color[1]*color[2],1.0/3.0); 

	color=log(color/gm);

	vec2 chi=vec2(dot(color,vec3(0.81650,-0.40825,-0.40825)),

	dot(color,vec3(0.0,-0.70711,0.70711))); 

	float s=dot(chi,ePerp); // projection

	chi=offset*vec2(sin(theta),-cos(theta))+s*ePerp;
	color=vec3(0.8165*chi[0],dot(chi,vec2(-0.40825,-0.70711)), dot(chi,vec2(-0.40825,+0.70711))); // insert shading code here

	gl_FragColor=vec4(s+1.0); // Figure 9(c) gl_FragColor=vec4(color,1.0); // Figure 9(e)
}
