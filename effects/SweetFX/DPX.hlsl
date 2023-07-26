/**
 * DPX/Cineon shader by Loadus
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL RGB Curve (Red)
//!DEFAULT 8.0
//!MIN 1.0
//!MAX 15.0
//!STEP 0.1
float RGB_Curve_Red;

//!PARAMETER
//!LABEL RGB Curve (Green)
//!DEFAULT 8.0
//!MIN 1.0
//!MAX 15.0
//!STEP 0.1
float RGB_Curve_Green;

//!PARAMETER
//!LABEL RGB Curve (Blue)
//!DEFAULT 8.0
//!MIN 1.0
//!MAX 15.0
//!STEP 0.1
float RGB_Curve_Blue;

//!PARAMETER
//!LABEL RGB C (Red)
//!DEFAULT 0.36
//!MIN 0.2
//!MAX 0.5
//!STEP 0.01
float RGB_C_Red;

//!PARAMETER
//!LABEL RGB C (Green)
//!DEFAULT 0.36
//!MIN 0.2
//!MAX 0.5
//!STEP 0.01
float RGB_C_Green;

//!PARAMETER
//!LABEL RGB C (Blue)
//!DEFAULT 0.34
//!MIN 0.2
//!MAX 0.5
//!STEP 0.01
float RGB_C_Blue;

//!PARAMETER
//!LABEL Contrast
//!DEFAULT 0.1
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Contrast;

//!PARAMETER
//!LABEL Saturation
//!DEFAULT 3.0
//!MIN 0.0
//!MAX 8.0
//!STEP 0.01
float Saturation;

//!PARAMETER
//!LABEL Colorfulness
//!DEFAULT 2.5
//!MIN 0.1
//!MAX 2.5
//!STEP 0.01
float Colorfulness;

//!PARAMETER
//!LABEL Strength
// Adjust the strength of the effect
//!DEFAULT 0.20
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Strength;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!SAMPLER
//!FILTER LINEAR
SamplerState SampleLinear;

//!PASS 1
//!DESC DPX
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 RGB_C = float3(RGB_C_Red, RGB_C_Green, RGB_C_Blue);
	float3 RGB_Curve = float3(RGB_Curve_Red, RGB_Curve_Green, RGB_Curve_Blue);

	float3x3 RGB = float3x3(
		2.6714711726599600, -1.2672360578624100, -0.4109956021722270,
		-1.0251070293466400,  1.9840911624108900,  0.0439502493584124,
		0.0610009456429445, -0.2236707508128630,  1.1590210416706100
	);

	float3x3 XYZ = float3x3(
		0.5003033835433160,  0.3380975732227390,  0.1645897795458570,
		0.2579688942747580,  0.6761952591447060,  0.0658358459823868,
		0.0234517888692628,  0.1126992737203000,  0.8668396731242010
	);

	float3 input = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;

	float3 B = input;
	B = B * (1.0 - Contrast) + (0.5 * Contrast);
	float3 Btemp = (1.0 / (1.0 + exp(RGB_Curve / 2.0)));
	B = ((1.0 / (1.0 + exp(-RGB_Curve * (B - RGB_C)))) / (-2.0 * Btemp + 1.0)) + (-Btemp / (-2.0 * Btemp + 1.0));

	float value = max(max(B.r, B.g), B.b);
	float3 color = B / value;
	color = pow(abs(color), 1.0 / Colorfulness);

	float3 c0 = color * value;
	c0 = mul(XYZ, c0);
	float luma = dot(c0, float3(0.30, 0.59, 0.11));
	c0 = (1.0 - Saturation) * luma + Saturation * c0;
	c0 = mul(RGB, c0);

	return lerp(input, c0, Strength);
}