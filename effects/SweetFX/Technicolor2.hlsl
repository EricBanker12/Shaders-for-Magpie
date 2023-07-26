/**
 * Technicolor2 version 1.0
 * Original by Prod80
 * Optimized by CeeJay.dk
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Color Strength (Red)
// Higher means darker and more intense colors.
//!DEFAULT 0.2
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorStrengthRed;

//!PARAMETER
//!LABEL Color Strength (Green)
// Higher means darker and more intense colors.
//!DEFAULT 0.2
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorStrengthGreen;

//!PARAMETER
//!LABEL Color Strength (Blue)
// Higher means darker and more intense colors.
//!DEFAULT 0.2
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorStrengthBlue;

//!PARAMETER
//!LABEL Brightness
// Higher means brighter image.
//!DEFAULT 1.0
//!MIN 0.5
//!MAX 1.5
//!STEP 0.01
float Brightness;

//!PARAMETER
//!LABEL Saturation
// Additional saturation control since this effect tends to oversaturate the image.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 1.5
//!STEP 0.01
float Saturation;

//!PARAMETER
//!LABEL Saturation
// Adjust the strength of the effect.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Strength;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Saturates colors for technicolor effect.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	
	float3 temp = 1.0 - color;
	float3 target = temp.grg;
	float3 target2 = temp.bbr;
	float3 temp2 = color * target;
	temp2 *= target2;

	temp = temp2 * float3(ColorStrengthRed, ColorStrengthGreen, ColorStrengthBlue);
	temp2 *= Brightness;

	target = temp.grg;
	target2 = temp.bbr;

	temp = color - target;
	temp += temp2;
	temp2 = temp - target2;

	color = lerp(color, temp2, Strength);
	color = lerp(dot(color, 0.333), color, Saturation);

	return color;
}