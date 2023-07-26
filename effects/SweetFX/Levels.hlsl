/**
 * Levels version 1.2
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 *
 * Ported to Magpie by Eric Banker ~ Kourinn
 *
 * Allows you to set a new black and a white level.
 * This increases contrast, but clips any colors outside the new range to either black or white
 * and so some details in the shadows or highlights can be lost.
 *
 * The shader is very useful for expanding the 16-235 TV range to 0-255 PC range.
 * You might need it if you're playing a game meant to display on a TV with an emulator that does not do this.
 * But it's also a quick and easy way to uniformly increase the contrast of an image.
 *
 * -- Version 1.0 --
 * First release
 * -- Version 1.1 --
 * Optimized to only use 1 instruction (down from 2 - a 100% performance increase :) )
 * -- Version 1.2 --
 * Added the ability to highlight clipping regions of the image with #define HighlightClipping 1
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Black Point
// The black point is the new black - literally. Everything darker than this will become completely black.
//!DEFAULT 16
//!MIN 0
//!MAX 255
//!STEP 1
int BlackPoint;

//!PARAMETER
//!LABEL White Point
// The new white point. Everything brighter than this becomes completely white.
//!DEFAULT 235
//!MIN 0
//!MAX 255
//!STEP 1
int WhitePoint;

//!PARAMETER
//!LABEL Highlight Clipping pixels
// Colors between the two points will stretched, which increases contrast, but details above and below the points are lost (this is called clipping).
// This setting marks the pixels that clip.
// Red: Some detail is lost in the highlights.
// Yellow: All detail is lost in the highlights.
// Blue: Some detail is lost in the shadows.
// Cyan: All detail is lost in the shadows.
//!DEFAULT 0
//!MIN 0
//!MAX 1
//!STEP 1
int HighlightClipping;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Allows you to set a new black and a white level. This increases contrast, but clips any colors outside the new range to either black or white and so some details in the shadows or highlights can be lost.
// You can use a PS-like style, but it will still be implemented with CS.
// The default value of "STYLE" is "CS".
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float black_point_float = BlackPoint / 255.0;
	float white_point_float = WhitePoint == BlackPoint ? (255.0 / 0.00025) : (255.0 / (WhitePoint - BlackPoint)); // Avoid division by zero if the white and black point are the same

	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	color = color * white_point_float - (black_point_float *  white_point_float);

	if (HighlightClipping == 1)
	{
		float3 clipped_colors;

		clipped_colors = any(color > saturate(color)) // any colors whiter than white?
			? float3(1.0, 0.0, 0.0)
			: color;
		clipped_colors = all(color > saturate(color)) // all colors whiter than white?
			? float3(1.0, 1.0, 0.0)
			: clipped_colors;
		clipped_colors = any(color < saturate(color)) // any colors blacker than black?
			? float3(0.0, 0.0, 1.0)
			: clipped_colors;
		clipped_colors = all(color < saturate(color)) // all colors blacker than black?
			? float3(0.0, 1.0, 1.0)
			: clipped_colors;

		color = clipped_colors;
	}

	return color;
}