/**
 * Lift Gamma Gain version 1.1
 * by 3an and CeeJay.dk
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL RGB Lift/Shadows (Red)
// Adjust shadows for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Lift_Red;

//!PARAMETER
//!LABEL RGB Lift/Shadows (Green)
// Adjust shadows for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Lift_Green;

//!PARAMETER
//!LABEL RGB Lift/Shadows (Blue)
// Adjust shadows for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Lift_Blue;

//!PARAMETER
//!LABEL RGB Gamma/Midtones (Red)
// Adjust midtones for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Gamma_Red;

//!PARAMETER
//!LABEL RGB Gamma/Midtones (Green)
// Adjust midtones for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Gamma_Green;

//!PARAMETER
//!LABEL RGB Gamma/Midtones (Blue)
// Adjust midtones for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Gamma_Blue;

//!PARAMETER
//!LABEL RGB Gain/Highlights (Red)
// Adjust highlights for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Gain_Red;

//!PARAMETER
//!LABEL RGB Gain/Highlights (Green)
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Gain_Green;

//!PARAMETER
//!LABEL RGB Gain/Highlights (Blue)
// Adjust highlights for red, green and blue.
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float RGB_Gain_Blue;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Distorts the image by shifting each color component, which creates color artifacts similar to those in a very cheap lens or a cheap sensor.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	float3 RGB_Lift = float3(RGB_Lift_Red, RGB_Lift_Green, RGB_Lift_Blue);
	float3 RGB_Gamma = float3(RGB_Gamma_Red, RGB_Gamma_Green, RGB_Gamma_Blue);
	float3 RGB_Gain = float3(RGB_Gain_Red, RGB_Gain_Green, RGB_Gain_Blue);
	
	// -- Lift --
	color = color * (1.5 - 0.5 * RGB_Lift) + 0.5 * RGB_Lift - 0.5;
	color = saturate(color); // Is not strictly necessary, but does not cost performance
	
	// -- Gain --
	color *= RGB_Gain; 
	
	// -- Gamma --
	color = pow(abs(color), 1.0 / RGB_Gamma);
	
	return saturate(color);
}
