/**
 * Border version 1.4.1
 *
 * -- Version 1.0 by Oomek --
 * Fixes light, one pixel thick border in some games when forcing MSAA like i.e. Dishonored
 * -- Version 1.1 by CeeJay.dk --
 * Optimized the shader. It still does the same but now it runs faster.
 * -- Version 1.2 by CeeJay.dk --
 * Added border_width and border_color features
 * -- Version 1.3 by CeeJay.dk --
 * Optimized the performance further
 * -- Version 1.4 by CeeJay.dk --
 * Added the border_ratio feature
 * -- Version 1.4.1 by CeeJay.dk --
 * Cleaned up setting for Reshade 3.x
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Border Width (Pixels)
// Measured in pixels. If this is set to zero then the ratio will be used instead.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1000.0
//!STEP 5.0
float border_width;

//!PARAMETER
//!LABEL Border Height (Pixels)
// Measured in pixels. If this is set to zero then the ratio will be used instead.
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1000.0
//!STEP 5.0
float border_height;

//!PARAMETER
//!LABEL Border Size (Aspect Ratio)
// Set the desired ratio for the visible area.
//!DEFAULT 2.35
//!MIN 0.25
//!MAX 4.0
//!STEP 0.01
float border_ratio;

//!PARAMETER
//!LABEL Border Color (Red)
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float border_color_Red;

//!PARAMETER
//!LABEL Border Color (Green)
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float border_color_Green;

//!PARAMETER
//!LABEL Border Color (Blue)
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float border_color_Blue;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Creates a border around top/bottom or sides of the window.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	float3 border_color = float3(border_color_Red, border_color_Green, border_color_Blue) / 255.0;
	float2 inputSize = float2(GetInputSize());
	float2 pixSize = GetInputPt();

	// -- calculate the right border_width for a given border_ratio --
	float2 border_width_variable = float2(border_width, border_height);
	if (border_width == -border_height) // If width is not used
		if (inputSize.x / inputSize.y < border_ratio)
			border_width_variable = float2(0.0, (inputSize.y - (inputSize.x / border_ratio)) * 0.5);
		else
			border_width_variable = float2((inputSize.x - (inputSize.y * border_ratio)) * 0.5, 0.0);

	float2 border = (pixSize * border_width_variable); // Translate integer pixel width to floating point
	float2 within_border = saturate((-texcoord * texcoord + texcoord) - (-border * border + border)); // Becomes positive when inside the border and zero when outside

	return lerp(border_color, color, float(all(within_border)));
}
