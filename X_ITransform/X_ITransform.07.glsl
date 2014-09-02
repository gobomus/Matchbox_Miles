uniform sampler2D adsk_results_pass6;
uniform float adsk_result_w, adsk_result_h;

float FXAA_SPAN_MAX = 18.0;
float FXAA_REDUCE_MUL = 1.0/8.0;
float FXAA_REDUCE_MIN = 1.0/128.0;

void main( void ) {
		vec2 texCoords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
		vec2 frameBufSize = vec2(adsk_result_w, adsk_result_h);


        //float FXAA_SPAN_MAX = 8.0;
        //float FXAA_REDUCE_MUL = 1.0/8.0;
        //float FXAA_REDUCE_MIN = 1.0/128.0;

        vec4 rgbNW=texture2D(adsk_results_pass6,texCoords+(vec2(-1.0,-1.0)/frameBufSize));
        vec4 rgbNE=texture2D(adsk_results_pass6,texCoords+(vec2(1.0,-1.0)/frameBufSize));
        vec4 rgbSW=texture2D(adsk_results_pass6,texCoords+(vec2(-1.0,1.0)/frameBufSize));
        vec4 rgbSE=texture2D(adsk_results_pass6,texCoords+(vec2(1.0,1.0)/frameBufSize));
        vec4 rgbM=texture2D(adsk_results_pass6,texCoords);
        
        vec4 luma=vec4(0.299, 0.587, 0.114, 1.0);
        float lumaNW = dot(rgbNW, luma);
        float lumaNE = dot(rgbNE, luma);
        float lumaSW = dot(rgbSW, luma);
        float lumaSE = dot(rgbSE, luma);
        float lumaM  = dot(rgbM,  luma);
        
        float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
        float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
        
        vec2 dir;
        dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
        dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
        
        float dirReduce = max(
                (lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
                FXAA_REDUCE_MIN);
          
        float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
        
        dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
                  max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
                  dir * rcpDirMin)) / frameBufSize;
                
        vec4 rgbA = (1.0/2.0) * (
                texture2D(adsk_results_pass6, texCoords.xy + dir * (1.0/3.0 - 0.5)) +
                texture2D(adsk_results_pass6, texCoords.xy + dir * (2.0/3.0 - 0.5)));
        vec4 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
                texture2D(adsk_results_pass6, texCoords.xy + dir * (0.0/3.0 - 0.5)) +
                texture2D(adsk_results_pass6, texCoords.xy + dir * (3.0/3.0 - 0.5)));
        float lumaB = dot(rgbB, luma);

        if((lumaB < lumaMin) || (lumaB > lumaMax)){
                gl_FragColor=rgbA;
        }else{
                gl_FragColor=rgbB;
        }
}

