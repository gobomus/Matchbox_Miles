#version 120
#extension GL_ARB_shader_texture_lod : enable

#define INPUT Front
#define NORMALS Normals
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define center vec2(.5)

#define luma(col) sqrt(dot(col * col, vec3(0.299, 0.587, 0.114)))
#define tex(col, coords) texture2D(col, coords).rgb
#define oc gl_FragColor.rgb

uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D INPUT;
uniform sampler2D NORMALS;

uniform vec3 lig_pos;
uniform int sn;
uniform float color;
uniform float radius, el;


uniform float Angle; // range 2pi / 100000.0 to 1.0 (rounded down), exponential
uniform float AngleMin; // range -3.2 to 3.2
uniform float AngleWidth; // range 0.0 to 6.4
uniform float Radius; // range -10000.0 to 1.0
uniform float RadiusMin; // range 0.0 to 2.0
uniform float RadiusWidth; // range 0.0 to 2.0




float map(in vec3 p)
{
	float d1 = length(p) - 1.0;
	return d1;
}

vec3 calcNormal(in vec3 p) 
{
	vec2 e = vec2(0.0001, 0.0);
	return normalize(vec3(
						map(p+e.xyy) - map(p-e.xyy),
						map(p+e.yxy) - map(p-e.yxy),
						map(p+e.yyx) - map(p-e.yyx)
					));
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / res;

	//coords go from -1 to 1
	vec2 p = -1.0 + 2.0 * uv;
	p.x *= ratio;

	//camera position
	vec3 ro = vec3(0.0, 0.0, 2.0);

	vec3 rd = normalize(vec3(p, -1.0));

	vec3 col = vec3(0.0);

	float tmax = 20.0;
	float h = 1.0;
	float t = 0.0;
	
	// t is distance to intersection
	
	//ray marching
	for (int i=0; i<sn; i++) {
		if(h < 0.0001 || t > tmax) break;
		h = map(ro + t * rd);
		t += h;

	}

	vec3 lig = lig_pos;

	vec2 normCoord = p;

	float r = length(p);
	float theta = atan(p.y, p.x);

	r = (r < RadiusMin) ? r : (r > RadiusMin + RadiusWidth) ? r : ceil(r / Radius) * Radius;
	theta = (theta < AngleMin) ? theta : (theta > AngleMin + AngleWidth) ? theta : floor(theta / Angle) * Angle;

	// Convert Polar back to Cartesian coords
	normCoord.x = r * cos(theta);
	normCoord.y = r * sin(theta);
	// Shift origin back to bottom-left (taking offset into account)
	uv.x = normCoord.x / 2.0 + (center.x / 2.0);
	uv.y = normCoord.y / 2.0 + (center.y / 2.0);


	vec2 mapc = vec2(r, 0);
	vec3 im = tex(INPUT, mapc);

	if (t < tmax) {
		vec3 pos = ro + t * rd;
		vec3 nor = calcNormal(pos);
		col = vec3(1.0);

		//Light the sphere
		col *= im * clamp(dot(nor, lig), 0.0, 1.0);
		
	}


	oc = col;
}
