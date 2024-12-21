#pragma header
uniform float valuable;
void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = getCamPos(openfl_TextureCoordv);

    // Time varying pixel color
    vec4 col = textureCam(bitmap, uv);
    if (sqrt(col.r * col.g * col.b) < valuable) col.rgb = vec3(0.0);
    // Output to screen
    gl_FragColor = col;
}