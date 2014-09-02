#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Front;

void main()
{
    vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
    vec4 front = texture2D(Front, st);

    gl_FragColor = front;
}

