/**
 * Tonemap version 1.1
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Gamma/Midtones
// Adjust midtones. 1.0 is neutral. This setting does exactly the same as the one in Lift Gamma Gain, only with less control.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float Gamma;

//!PARAMETER
//!LABEL Exposure
// Adjust exposure.
//!DEFAULT 0.0
//!MIN -1.0
//!MAX 1.0
//!STEP 0.01
float Exposure;

//!PARAMETER
//!LABEL Saturation
// Adjust saturation.
//!DEFAULT 0.0
//!MIN -1.0
//!MAX 1.0
//!STEP 0.01
float Saturation;

//!PARAMETER
//!LABEL Bleach
// Brightens the shadows and fades the colors.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Bleach;

//!PARAMETER
//!LABEL Defog
// How much of the color tint to remove.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Defog;

//!PARAMETER
//!LABEL Fog Color (Red)
// Which color tint to remove.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float FogColor_Red;

//!PARAMETER
//!LABEL Fog Color (Green)
// Which color tint to remove.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float FogColor_Green;

//!PARAMETER
//!LABEL Fog Color (Blue)
// Which color tint to remove.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float FogColor_Blue;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Changes color of the scene with simpler controls.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	float3 FogColor = float3(FogColor_Red, FogColor_Green, FogColor_Blue);
	color = saturate(color - Defog * FogColor * 2.55); // Defog
	color *= pow(2.0, Exposure); // Exposure
	color = pow(color, Gamma); // Gamma

	const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
	float lum = dot(coefLuma, color);
	
	float L = saturate(10.0 * (lum - 0.45));
	float3 A2 = Bleach * color;

	float3 result1 = 2.0 * color * lum;
	float3 result2 = 1.0 - 2.0 * (1.0 - lum) * (1.0 - color);
	
	float3 newColor = lerp(result1, result2, L);
	float3 mixRGB = A2 * newColor;
	color += ((1.0 - A2) * mixRGB);
	
	float3 middlegray = dot(color, (1.0 / 3.0));
	float3 diffcolor = color - middlegray;
	color = (color + diffcolor * Saturation) / (1 + (diffcolor * Saturation)); // Saturation
	
	return color;
}
