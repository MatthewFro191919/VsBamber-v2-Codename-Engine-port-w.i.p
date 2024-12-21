#pragma header
float rand(float x)
{
    return fract(sin(x) * 43758.5453);
}
void main()
{
    vec2 uv = openfl_TextureCoordv;
    // pixel position
    vec2 p = uv;    
    p += vec2(rand(p.x * 3.1 + p.y * 8.7) * 0.05 - 0.05/2.0,
              rand(p.x * 1.1 + p.y * 6.7) * 0.05 - 0.05/2.0);
    vec4 baseColor = textureCam(bitmap, getCamPos(p));
    vec4 edges = 0.7 - baseColor / (textureCam(bitmap,getCamPos(uv)) - vec4(0.000001, 0.000001, 0.000001, 0));  
    gl_FragColor = baseColor / vec4(length(edges));
}