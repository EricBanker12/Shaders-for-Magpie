/**
 * HDR
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 *
 * Ported to Magpie by Eric Banker ~ Kourinn
 *
 * Not actual HDR - It just tries to mimic an HDR look (relatively high performance cost)
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Power
//!DEFAULT 1.3
//!MIN 0.0
//!MAX 8.0
//!STEP 0.01
float HDRPower;

//!PARAMETER
//!LABEL Radius 1
//!DEFAULT 0.79
//!MIN 0.0
//!MAX 8.0
//!STEP 0.01
float radius1;

//!PARAMETER
//!LABEL Radius 2
// Raising this seems to make the effect stronger and also brighter
//!DEFAULT 0.87
//!MIN 0.0
//!MAX 8.0
//!STEP 0.01
float radius2;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!SAMPLER
//!FILTER LINEAR
SamplerState SampleLinear;

//!PASS 1
//!DESC Not actual HDR - It just tries to mimic an HDR look (relatively high performance cost).
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	float2 pixSize = GetInputPt();

	float3 bloom_sum1 = INPUT.SampleLevel(SampleLinear, texcoord + float2(1.5, -1.5) * radius1 * pixSize, 0).rgb;
	bloom_sum1 += INPUT.SampleLevel(SampleLinear, texcoord + float2(-1.5, -1.5) * radius1 * pixSize, 0).rgb;
	bloom_sum1 += INPUT.SampleLevel(SampleLinear, texcoord + float2(1.5, 1.5) * radius1 * pixSize, 0).rgb;
	bloom_sum1 += INPUT.SampleLevel(SampleLinear, texcoord + float2(-1.5, 1.5) * radius1 * pixSize, 0).rgb;
	bloom_sum1 += INPUT.SampleLevel(SampleLinear, texcoord + float2(0, -2.5) * radius1 * pixSize, 0).rgb;
	bloom_sum1 += INPUT.SampleLevel(SampleLinear, texcoord + float2(0, 2.5) * radius1 * pixSize, 0).rgb;
	bloom_sum1 += INPUT.SampleLevel(SampleLinear, texcoord + float2(-2.5, 0) * radius1 * pixSize, 0).rgb;
	bloom_sum1 += INPUT.SampleLevel(SampleLinear, texcoord + float2(2.5, 0) * radius1 * pixSize, 0).rgb;

	bloom_sum1 *= 0.005;

	float3 bloom_sum2 = INPUT.SampleLevel(SampleLinear, texcoord + float2(1.5, -1.5) * radius2 * pixSize, 0).rgb;
	bloom_sum2 += INPUT.SampleLevel(SampleLinear, texcoord + float2(-1.5, -1.5) * radius2 * pixSize, 0).rgb;
	bloom_sum2 += INPUT.SampleLevel(SampleLinear, texcoord + float2(1.5, 1.5) * radius2 * pixSize, 0).rgb;
	bloom_sum2 += INPUT.SampleLevel(SampleLinear, texcoord + float2(-1.5, 1.5) * radius2 * pixSize, 0).rgb;
	bloom_sum2 += INPUT.SampleLevel(SampleLinear, texcoord + float2(0, -2.5) * radius2 * pixSize, 0).rgb;
	bloom_sum2 += INPUT.SampleLevel(SampleLinear, texcoord + float2(0, 2.5) * radius2 * pixSize, 0).rgb;
	bloom_sum2 += INPUT.SampleLevel(SampleLinear, texcoord + float2(-2.5, 0) * radius2 * pixSize, 0).rgb;
	bloom_sum2 += INPUT.SampleLevel(SampleLinear, texcoord + float2(2.5, 0) * radius2 * pixSize, 0).rgb;

	bloom_sum2 *= 0.010;

	float dist = radius2 - radius1;
	float3 HDR = (color + (bloom_sum2 - bloom_sum1)) * dist;
	float3 blend = HDR + color;
	color = pow(abs(blend), abs(HDRPower)) + HDR; // pow - don't use fractions for HDRpower
	
	return saturate(color);
}