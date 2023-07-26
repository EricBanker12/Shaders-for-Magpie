/**
 * Vignette version 1.3
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 *
 * Ported to Magpie by Eric Banekr ~ Kourinn
 *
 * Darkens the edges of the image to make it look more like it was shot with a camera lens.
 * May cause banding artifacts.
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Type
// 0: Original, 1: New, 2: TV style, 3: Untitled 1, 4: Untitled 2, 5: Untitled 3, 6: Untitled 4
//!DEFAULT 0
//!MIN 0
//!MAX 6
//!STEP 1
int Type;

//!PARAMETER
//!LABEL Ratio
// Sets a width to height ratio. 1.00 (1/1) is perfectly round, while 1.60 (16/10) is 60 % wider than it's high.
//!DEFAULT 1.0
//!MIN 0.15
//!MAX 6.0
//!STEP 0.01
float Ratio;

//!PARAMETER
//!LABEL Radius
// lower values = stronger radial effect from center.
//!DEFAULT 2.0
//!MIN -1.0
//!MAX 3.0
//!STEP 0.01
float Radius;

//!PARAMETER
//!LABEL Amount
// Strength of black. -2.00 = Max Black, 1.00 = Max White.
//!DEFAULT -1.0
//!MIN -2.0
//!MAX 1.0
//!STEP 0.01
float Amount;

//!PARAMETER
//!LABEL Slope
// How far away from the center the change should start to really grow strong (odd numbers cause a larger fps drop than even numbers).
//!DEFAULT 2
//!MIN 2
//!MAX 16
//!STEP 1
int Slope;

//!PARAMETER
//!LABEL Center X-axis
// Center of effect for 'Original' vignette type. 'New' and 'TV style' do not obey this setting.
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float CenterX;

//!PARAMETER
//!LABEL Center Y-axis
// Center of effect for 'Original' vignette type. 'New' and 'TV style' do not obey this setting.
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float CenterY;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Darkens the edges of the image to make it look more like it was shot with a camera lens. May cause banding artifacts.
//!STYLE PS
//!IN INPUT
float4 Pass1(float2 tex) {
	float4 color = INPUT.SampleLevel(SamplePoint, tex, 0);
	float2 Center = float2(CenterX, CenterY);
	float2 texSize = GetInputPt();

	if (Type == 0)
	{
		// Set the center
		float2 distance_xy = tex - Center;

		// Adjust the ratio
		distance_xy *= float2((texSize.y / texSize.x), Ratio);

		// Calculate the distance
		distance_xy /= Radius;
		float distance = dot(distance_xy, distance_xy);

		// Apply the vignette
		color.rgb *= (1.0 + pow(distance, Slope * 0.5) * Amount); //pow - multiply
	}

	if (Type == 1) // New round (-x*x+x) + (-y*y+y) method.
	{
		tex = -tex * tex + tex;
		color.rgb = saturate(((texSize.y / texSize.x)*(texSize.y / texSize.x) * Ratio * tex.x + tex.y) * 4.0) * color.rgb;
	}

	if (Type == 2) // New (-x*x+x) * (-y*y+y) TV style method.
	{
		tex = -tex * tex + tex;
		color.rgb = saturate(tex.x * tex.y * 100.0) * color.rgb;
	}
		
	if (Type == 3)
	{
		tex = abs(tex - 0.5);
		float tc = dot(float4(-tex.x, -tex.x, tex.x, tex.y), float4(tex.y, tex.y, 1.0, 1.0)); //XOR

		tc = saturate(tc - 0.495);
		color.rgb *= (pow((1.0 - tc * 200), 4) + 0.25); //or maybe abs(tc*100-1) (-(tc*100)-1)
	}
  
	if (Type == 4)
	{
		tex = abs(tex - 0.5);
		float tc = dot(float4(-tex.x, -tex.x, tex.x, tex.y), float4(tex.y, tex.y, 1.0, 1.0)); //XOR

		tc = saturate(tc - 0.495) - 0.0002;
		color.rgb *= (pow((1.0 - tc * 200), 4) + 0.0); //or maybe abs(tc*100-1) (-(tc*100)-1)
	}

	if (Type == 5) // MAD version of 2
	{
		tex = abs(tex - 0.5);
		float tc = tex.x * (-2.0 * tex.y + 1.0) + tex.y; //XOR

		tc = saturate(tc - 0.495);
		color.rgb *= (pow((-tc * 200 + 1.0), 4) + 0.25); //or maybe abs(tc*100-1) (-(tc*100)-1)
		//color.rgb *= (pow(((tc*200.0)-1.0),4)); //or maybe abs(tc*100-1) (-(tc*100)-1)
	}

	if (Type == 6) // New round (-x*x+x) * (-y*y+y) method.
	{
		//tex.y /= float2((BUFFER_RCP_HEIGHT / BUFFER_RCP_WIDTH), Ratio);
		float tex_xy = dot(float4(tex, tex), float4(-tex, 1.0, 1.0)); //dot is actually slower
		color.rgb = saturate(tex_xy * 4.0) * color.rgb;
	}

	return color;
}