#pragma header
float NoiseSeed;
float randomFloat(){
  NoiseSeed = sin(NoiseSeed) * 84522.13219145687;
  return fract(NoiseSeed);
}

float SCurve (float value, float amount, float correction) {

	float curve = 1.0; 

    if (value < 0.5)
    {

        curve = pow(value, amount) * pow(2.0, amount) * 0.5; 
    }
        
    else
    { 	
    	curve = 1.0 - pow(1.0 - value, amount) * pow(2.0, amount) * 0.5; 
    }

    return pow(curve, correction);
}




//ACES tonemapping from: https://www.shadertoy.com/view/wl2SDt
vec3 ACESFilm(vec3 x)
{
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return (x*(a*x+b))/(x*(c*x+d)+e);
}

//Sigmoid Contrast from: https://www.shadertoy.com/view/MlXGRf
vec3 contrast(vec3 color)
{
    return vec3(SCurve(color.r, 3.0, 1.0), 
                SCurve(color.g, 4.0, 0.7), 
                SCurve(color.b, 2.6, 0.6)
               );
}

//glow from: https://www.shadertoy.com/view/XslGDr (unused but useful)
vec3 samplef(vec2 tc, vec3 color)
{
	return pow(color, vec3(2.2, 2.2, 2.2));
}

vec3 highlights(vec3 pixel, float thres)
{
	float val = (pixel.x + pixel.y + pixel.z) / 3.0;
	return pixel * smoothstep(thres - 0.1, thres + 0.1, val);
}

vec3 hsample(vec3 color, vec2 tc)
{
	return highlights(samplef(tc, color), 0.6);
}

vec3 blur(vec3 col, vec2 tc, float offs)
{
	vec4 xoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.x;
	vec4 yoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.y;
	
	vec3 color = vec3(0.0, 0.0, 0.0);
	color += hsample(col, tc + vec2(xoffs.x, yoffs.x)) * 0.00366;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.x)) * 0.01465;
	color += hsample(col, tc + vec2(    0.0, yoffs.x)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.x)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.x)) * 0.00366;
	
	color += hsample(col, tc + vec2(xoffs.x, yoffs.y)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.y)) * 0.05861;
	color += hsample(col, tc + vec2(    0.0, yoffs.y)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.y)) * 0.05861;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.y)) * 0.01465;
	
	color += hsample(col, tc + vec2(xoffs.x, 0.0)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.y, 0.0)) * 0.09524;
	color += hsample(col, tc + vec2(    0.0, 0.0)) * 0.15018;
	color += hsample(col, tc + vec2(xoffs.z, 0.0)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.w, 0.0)) * 0.02564;
	
	color += hsample(col, tc + vec2(xoffs.x, yoffs.z)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.z)) * 0.05861;
	color += hsample(col, tc + vec2(    0.0, yoffs.z)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.z)) * 0.05861;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.z)) * 0.01465;
	
	color += hsample(col, tc + vec2(xoffs.x, yoffs.w)) * 0.00366;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.w)) * 0.01465;
	color += hsample(col, tc + vec2(    0.0, yoffs.w)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.w)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.w)) * 0.00366;

	return color;
}

vec3 glow(vec3 col, vec2 uv)
{
    vec3 color = blur(col, uv, 2.0);
	color += blur(col, uv, 3.0);
	color += blur(col, uv, 5.0);
	color += blur(col, uv, 7.0);
	color /= 4.0;
	
	color += samplef(uv, col);
    
    return color;
}

void main() {
    
    vec2 uv = getCamPos(openfl_TextureCoordv);
    
    vec3 color = textureCam(bitmap, uv).xyz;
    
    //ACES Tonemapping
    color = ACESFilm(color);
    
    
    //contrast
    color = contrast(color) * 0.7;
    
    color += glow(color, uv) * 1.2;
    
    //output
    gl_FragColor = textureCam(bitmap, uv);
    gl_FragColor.rgb = color;
}