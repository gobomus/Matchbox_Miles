#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Back;

void main()
{
    vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
    vec4 back = texture2D(Back, st);

    gl_FragColor = back;
}

