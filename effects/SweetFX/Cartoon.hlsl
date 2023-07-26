/**
 * Cartoon
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Power
// Amount of effect you want.
//!DEFAULT 1.5
//!MIN 0.1
//!MAX 10.0
//!STEP 0.1
float Power;

//!PARAMETER
//!LABEL Edge Slope Filter
// Raise this to filter out fainter edges. You might need to increase the power to compensate. Whole numbers are faster.
//!DEFAULT 1.5
//!MIN 0.1
//!MAX 6.0
//!STEP 0.1
float EdgeSlope;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Outlines edges in a cartoon-like manner.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	const float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
	const float2 pixSize = GetInputPt();

	float diff1 = dot(coefLuma, INPUT.SampleLevel(SamplePoint, texcoord + pixSize, 0).rgb);
	diff1 = dot(float4(coefLuma, -1.0), float4(INPUT.SampleLevel(SamplePoint, texcoord - pixSize, 0).rgb , diff1));
	float diff2 = dot(coefLuma, INPUT.SampleLevel(SamplePoint, texcoord + pixSize * float2(1.0, -1.0), 0).rgb);
	diff2 = dot(float4(coefLuma, -1.0), float4(INPUT.SampleLevel(SamplePoint, texcoord + pixSize * float2(-1.0, 1.0), 0).rgb , diff2));

	float edge = dot(float2(diff1, diff2), float2(diff1, diff2));

	return saturate(pow(abs(edge), EdgeSlope) * -Power + color);
}