#pragma header

#define wrap(x, _min, _max) (_min + mod(_max - _min + mod(x - _min, _max - _min), _max - _min));

uniform float uTime = 0.0;
uniform float speed = 0.0;

void main() {
    vec2 uv = openfl_TextureCoordv;
    uv.x -= wrap(uTime * speed, 0.0, 0.2);
    gl_FragColor = flixel_texture2D(bitmap, uv);
}