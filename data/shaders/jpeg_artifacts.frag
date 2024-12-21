#pragma header
uniform float blockSize;
uniform float quality;

vec3 rgb2ycbcr(vec3 rgb) {
    return vec3(
        0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b,
        -0.1687 * rgb.r - 0.3313 * rgb.g + 0.5 * rgb.b + 0.5,
        0.5 * rgb.r - 0.4187 * rgb.g - 0.0813 * rgb.b + 0.5
    );
}

vec3 ycbcr2rgb(vec3 ycbcr) {
    return vec3(
        ycbcr.r + 1.402 * (ycbcr.b - 0.5),
        ycbcr.r - 0.34414 * (ycbcr.g - 0.5) - 0.71414 * (ycbcr.b - 0.5),
        ycbcr.r + 1.772 * (ycbcr.g - 0.5)
    );
}

void main() {
    vec2 uv = getCamPos(openfl_TextureCoordv);
    vec4 color = textureCam(bitmap, uv);
    vec3 ycbcr = rgb2ycbcr(color.rgb);

    float blockQuality = quality * blockSize;
    vec2 blockPos = floor(uv * openfl_TextureSize.xy / blockSize);
    vec2 blockCoord = floor(fract(uv * openfl_TextureSize.xy / blockSize) * blockQuality) / blockQuality;

    vec2 quantizedCoord = (blockPos * blockSize + blockCoord) / openfl_TextureSize.xy;
    vec4 quantizedColor = textureCam(bitmap, quantizedCoord);
    vec3 quantizedYCbCr = rgb2ycbcr(quantizedColor.rgb);

    gl_FragColor = vec4(ycbcr2rgb(vec3(ycbcr.r, quantizedYCbCr.gb)), color.a);
}
