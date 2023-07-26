/**
  Vibrance
  by Christian Cann Schuldt Jensen ~ CeeJay.dk

  Ported to Magpie by Eric Banker ~ Kourinn
 
  Vibrance intelligently boosts the saturation of pixels so pixels that had little color get a larger boost than pixels that had a lot.
  This avoids oversaturation of pixels that were already very saturated.

  History:

  Version 1.0 by Ceejay.dk
  - Original 
  Version 1.1 by CeeJay.dk
  - Introduced RBG balance to help colorblind users
  Version 1.1.1
  - Minor UI improvements for Reshade 3.x
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Vibrance
// Intelligently saturates (or desaturates if you use negative values) the pixels depending on their original saturation.
//!DEFAULT 0.15
//!MIN -1.0
//!MAX 1.0
//!STEP 0.01
float Vibrance;

//!PARAMETER
//!LABEL Red Balance
// A per channel multiplier to the Vibrance strength so you can give more boost to certain colors over others.
// This is handy if you are colorblind and less sensitive to a specific color.
// You can then boost that color more than the others.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 10.0
//!STEP 0.01
float RedBalance;

//!PARAMETER
//!LABEL Green Balance
// A per channel multiplier to the Vibrance strength so you can give more boost to certain colors over others.
// This is handy if you are colorblind and less sensitive to a specific color.
// You can then boost that color more than the others.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 10.0
//!STEP 0.01
float GreenBalance;

//!PARAMETER
//!LABEL Blue Balance
// A per channel multiplier to the Vibrance strength so you can give more boost to certain colors over others.
// This is handy if you are colorblind and less sensitive to a specific color.
// You can then boost that color more than the others.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 10.0
//!STEP 0.01
float BlueBalance;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Vibrance intelligently boosts the saturation of pixels so pixels that had little color get a larger boost than pixels that had a lot. This avoids oversaturation of pixels that were already very saturated.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) : SV_Target
{
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
  
	float3 coefLuma = float3(0.212656, 0.715158, 0.072186);
	
	/*
	if (Vibrance_Luma)
		coefLuma = float3(0.333333, 0.333334, 0.333333);
	*/
	
	float luma = dot(coefLuma, color);


	float max_color = max(color.r, max(color.g, color.b)); // Find the strongest color
	float min_color = min(color.r, min(color.g, color.b)); // Find the weakest color

	float color_saturation = max_color - min_color; // The difference between the two is the saturation

	// Extrapolate between luma and original by 1 + (1-saturation) - current
	float3 coeffVibrance = float3(RedBalance, GreenBalance, BlueBalance) * Vibrance;
	color = lerp(luma, color, 1.0 + (coeffVibrance * (1.0 - (sign(coeffVibrance) * color_saturation))));

	return color;
}