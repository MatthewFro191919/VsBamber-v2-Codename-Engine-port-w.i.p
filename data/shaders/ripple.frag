#pragma header

uniform float uTime;

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec4 color = flixel_texture2D(bitmap, uv);

    // Calculate displacement based on time
    float displacement = sin(uTime * 10.0 + uv.y * 10.0) / 20.0;
    uv.x += displacement;

    // Sample texture again and multiply color values to create alpha mask effect
    vec4 mask = flixel_texture2D(bitmap, uv);
    color *= mask;

    gl_FragColor = color;
}

