#pragma header

uniform float timeOfDay; // The time of day represented as a float from 0-24

vec4 colors[9] = vec4[](vec4(0.0, 0.0, 0.25, 1.0), vec4(0.1, 0.0, 0.25, 1.0), vec4(0.5, 0.0, 0.8, 1.0), vec4(1.0, 0.7, 0.5, 1.0), vec4(1.0, 1.0, 1.0, 1.0), vec4(1.0, 0.7, 0.5, 1.0), vec4(0.5, 0.0, 0.8, 1.0), vec4(0.1, 0.0, 0.25, 1.0), vec4(0.0, 0.0, 0.25, 1.0)); // Array of color values
float intervals[9] = float[](0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0, 21.0, 24.0); // Array of interval start times

void main() {
    vec4 currentColor = textureCam(bitmap, openfl_TextureCoordv).rgba; // Get the current color value
    vec4 finalColor;

    for (int i = 0; i < intervals.length() - 1; i++) {
        if (timeOfDay >= intervals[i] && timeOfDay < intervals[i + 1]) {
            finalColor = mix(colors[i], colors[i + 1], (timeOfDay - intervals[i]) / (intervals[i + 1] - intervals[i]));
            break;
        }
    }

    gl_FragColor = vec4(finalColor.rgb * currentColor.rgb, currentColor.a);
}