#pragma header
uniform float iTime;
vec2 Remap(vec2 p, float b, float l, float t, float r) {
    return vec2( (p.x-l) / (r-l), (p.y-b) / (t-b));
}

vec4 Flag(vec2 uv) {
    float y = sin(uv.y*3.1415*13.);
    float w = fwidth(y);
    w = fwidth(uv.y);
    vec4 col;
    if (uv.y >= 0.5)
        col.rgb = vec3(0.824,0.149,0.188);
    else
        col.rgb = vec3(1,1,1);
    
    vec2 st = Remap(uv, .46, 0., 1., .4);
    
    float size = .07;
    if(st.x>0. && st.x<1. && st.y>0. && st.y<1.) {        
        vec2 gv = fract( st*vec2(6,5) )-.5;
        st = Remap(st, .1, .0833, .9, .9166);
        if(st.x>0. && st.x<1. && st.y>0. && st.y<1.) { 
            vec2 gv = fract( st*vec2(5,4) )-.5;
        }
    }
    
    col.rgb *= smoothstep(w, .0, abs(uv.y-.5)-.5+w);
    return col;
}


void main()
{
    vec2 uv = openfl_TextureCoordv;

    float t = uv.x*7.-2.*iTime+uv.y*3.;
    uv.y += sin(t)*.05;
    
    vec4 col = Flag(uv);
    
    col.rgb = col.rgb / .7+cos(t)*.3;
    gl_FragColor = col;
}