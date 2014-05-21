#version 120

bool isInTex( const vec2 coords )
{
	return coords.x >= 0.0 && coords.x <= 1.0 &&
			coords.y >= 0.0 && coords.y <= 1.0;
}

vec2 translate(vec2 st, vec2 center, vec2 position)
{
	return (st - position) + center;

}

vec2 uniform_scale(vec2 st, vec2 center, float scale) 
{
	vec2 ss = vec2(scale / vec2(100.0));

	return (st - center) / ss + center;
}

vec2 rotate(vec2 coords, vec2 center, float rotation)
{
	mat2 rotationMatrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );

   	coords -= center;
   	coords.x *= adsk_result_frameratio;
   	coords *= rotationMatrice;
   	coords.x /= adsk_result_frameratio;
   	coords += center;

	return coords;
}

vec2 barrel_distort(vec2 coords, vec2 center, float barrel)
{
	vec2 cc = coords - center;
	float dist = dot(cc, cc);
	coords = coords + cc * dist * barrel;

	return coords;
}

