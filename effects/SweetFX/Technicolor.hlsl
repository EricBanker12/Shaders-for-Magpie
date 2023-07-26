/**
 * Technicolor version 1.1
 * Original by DKT70
 * Optimized by CeeJay.dk
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Power
//!DEFAULT 4.0
//!MIN 0.0
//!MAX 8.0
//!STEP 0.01
float Power;

//!PARAMETER
//!LABEL RGB Negative Amount (Red)
//!DEFAULT 0.88
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float RGBNegativeAmountRed;

//!PARAMETER
//!LABEL RGB Negative Amount (Green)
//!DEFAULT 0.88
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float RGBNegativeAmountGreen;

//!PARAMETER
//!LABEL RGB Negative Amount (Blue)
//!DEFAULT 0.88
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float RGBNegativeAmountBlue;

//!PARAMETER
//!LABEL Strength
// Adjust the strength of the effect
//!DEFAULT 0.4
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
//!DESC Desaturates colors for technicolor effect.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	const float3 cyanfilter = float3(0.0, 1.30, 1.0);
	const float3 magentafilter = float3(1.0, 0.0, 1.05);
	const float3 yellowfilter = float3(1.6, 1.6, 0.05);
	const float2 redorangefilter = float2(1.05, 0.620); // RG_
	const float2 greenfilter = float2(0.30, 1.0);       // RG_
	const float2 magentafilter2 = magentafilter.rb;     // R_B

	float3 tcol = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	
	float2 negative_mul_r = tcol.rg * (1.0 / (RGBNegativeAmountRed * Power));
	float2 negative_mul_g = tcol.rg * (1.0 / (RGBNegativeAmountGreen * Power));
	float2 negative_mul_b = tcol.rb * (1.0 / (RGBNegativeAmountBlue * Power));
	float3 output_r = dot(redorangefilter, negative_mul_r).xxx + cyanfilter;
	float3 output_g = dot(greenfilter, negative_mul_g).xxx + magentafilter;
	float3 output_b = dot(magentafilter2, negative_mul_b).xxx + yellowfilter;

	return lerp(tcol, output_r * output_g * output_b, Strength);
}