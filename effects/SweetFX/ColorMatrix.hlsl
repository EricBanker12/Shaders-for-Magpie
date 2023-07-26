/**
 * Color Matrix version 1.0
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 *
 * Ported to Magpie by Eric Banker ~ Kourinn
 *
 * ColorMatrix allow the user to transform the colors using a color matrix
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Matrix Red To Red
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.82
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Red_Red;

//!PARAMETER
//!LABEL Matrix Green To Red
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.18
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Green_Red;

//!PARAMETER
//!LABEL Matrix Blue To Red
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Blue_Red;

//!PARAMETER
//!LABEL Matrix Red To Green
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.33
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Red_Green;

//!PARAMETER
//!LABEL Matrix Green To Green
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.67
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Green_Green;

//!PARAMETER
//!LABEL Matrix Blue To Green
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Blue_Green;

//!PARAMETER
//!LABEL Matrix Red To Blue
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Red_Blue;

//!PARAMETER
//!LABEL Matrix Green To Blue
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.13
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Green_Blue;

//!PARAMETER
//!LABEL Matrix Blue To Blue
// How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.
//!DEFAULT 0.87
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float ColorMatrix_Blue_Blue;

//!PARAMETER
//!LABEL Strength
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
//!DESC ColorMatrix allow the user to transform the colors using a color matrix.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;

	const float3x3 ColorMatrix = float3x3(
		float3(ColorMatrix_Red_Red, ColorMatrix_Green_Red, ColorMatrix_Blue_Red),
		float3(ColorMatrix_Red_Green, ColorMatrix_Green_Green, ColorMatrix_Blue_Green),
		float3(ColorMatrix_Red_Blue, ColorMatrix_Green_Blue, ColorMatrix_Blue_Blue)
	);
	color = lerp(color, mul(ColorMatrix, color), Strength);

	return saturate(color);
}