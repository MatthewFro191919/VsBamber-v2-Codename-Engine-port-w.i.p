#pragma header

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 deepfry(vec3 color) {
    // Increase saturation
    float saturation = 3.0;
    const vec3 luminance = vec3(0.2125, 0.7154, 0.0721);
    float intensity = dot(color, luminance);
    color = mix(vec3(intensity), color, saturation);

    // Increase contrast
    float contrast = 2.0;
    color = (color - 0.5) * contrast + 0.5;

    // Apply noise
    float noiseAmount = 0.1;
    float noise = rand(openfl_TextureCoordv) * noiseAmount;
    color += noise;

    return color;
}

void main() {
    vec4 texColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    texColor.rgb = deepfry(texColor.rgb);
    gl_FragColor = texColor;
}
