// Translate, rotate and scale a card...  a sane person would do this in a vertex shader
// lewis@lewissaunders.com

vec3 t = vec3(0.0, 0.0, 0.0);
vec3 r = vec3(-iMouse.y, -iMouse.x, 0.0);
vec2 s = vec2(1.0, 1.0);
float fov = 40.0; // Horizontal field of view

float deg2rad(float d) { return d * (3.14159265358/180.0); }

vec3 rotate(vec3 p, vec3 angles) {
	vec3 a = vec3(deg2rad(angles.x), deg2rad(angles.y), deg2rad(angles.z));
	mat3 rx = mat3(1.0, 0.0, 0.0, 0.0, cos(a.x), sin(a.x), 0.0, -sin(a.x), cos(a.x));
	mat3 ry = mat3(cos(a.y), 0.0, -sin(a.y), 0.0, 1.0, 0.0, sin(a.y), 0.0, cos(a.y));
	mat3 rz = mat3(cos(a.z), sin(a.z), 0.0, -sin(a.z), cos(a.z), 0.0, 0.0, 0.0, 1.0);
	return(p * ry * rx * rz); // ZXY rotation order
}

void main(void) {
	vec2 xy = gl_FragCoord.xy / iResolution.xy;
    float aspect = iResolution.x/iResolution.y;
    
    // Plane origin, normal, vectors along plane's uv axes
    vec3 po = t;
    vec3 pn = rotate(vec3(0.0, 0.0, 1.0), r);
    vec3 pu = rotate(vec3(1.0, 0.0, 0.0), r);
    vec3 pv = rotate(vec3(0.0, 1.0, 0.0), r);

    // Camera origin and ray direction, camera placed in Z to fill frame
	vec3 ro = vec3(0.0, 0.0, 0.5/tan(deg2rad(fov/2.0)));
	vec3 rd = normalize(vec3((-1.0 + 2.0*xy) * vec2(-aspect,1.0) * tan(deg2rad(fov/2.0)), 1.0));
    
    // Find which bit of plane is under this pixel, by ray-plane intersection
    vec3 p = ro + (dot(po - ro, pn) / dot(rd, pn)) * rd;
    
    // Find how far across and up the plane we are by comparing with plane's u and v axes
    vec2 uv = vec2(dot(p-po, pu)/aspect, dot(p-po, pv)) / s + vec2(0.5);
    vec4 c = texture2D(iChannel0, uv);
    if(uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) c = vec4(0.0);
    gl_FragColor = c;
}

