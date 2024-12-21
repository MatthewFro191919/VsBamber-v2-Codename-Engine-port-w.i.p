//TAKEN FROM OPENFL FILTERS

#pragma header

uniform mat4 uMultipliers;
uniform vec4 uOffsets;

void main() {
    vec4 color = textureCam(bitmap, getCamPos(openfl_TextureCoordv));

    if (color.a == 0.0) {
        gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
    } else {
        color = vec4 (color.rgb / color.a, color.a);
        color = uOffsets + color * uMultipliers;

        gl_FragColor = vec4 (color.rgb * color.a, color.a);
    }
}