//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Tint Color (Red Component)
//!DEFAULT 140.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float TintRed;

//!PARAMETER
//!LABEL Tint Color (Green Component)
//!DEFAULT 110.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float TintGreen;

//!PARAMETER
//!LABEL Tint Color (Blue Component)
//!DEFAULT 107.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float TintBlue;

//!PARAMETER
//!LABEL Strength
// Adjust the strength of the effect.
//!DEFAULT 0.58
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
//!DESC Curves, uses S-curves to increase contrast, without clipping highlights and shadows.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 col = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	float3 Tint = float3(TintRed, TintGreen, TintBlue) / 255.0;

	return lerp(col, col * Tint * 2.55, Strength);
}
