/*------------------.
| :: Description :: |
'-------------------/

	Monochrome (version 1.1)

	Author: CeeJay.dk
	License: MIT

	About:
	Removes color making everything monochrome.

	Ideas for future improvement:
	* Tinting
	* Select a hue to keep its color, thus making it stand out against a monochrome background
	* Try Lab colorspace
	* Apply color gradient
	* Add an option to normalize the coefficients
	* Publish best-selling book titled "256 shades of grey"

	History:
	(*) Feature (+) Improvement	(x) Bugfix (-) Information (!) Compatibility
	
	Version 1.0
	* Converts image to monochrome
	* Allows users to add saturation back in.

	Version 1.1 
	* Added many presets based on B/W camera films
	+ Improved settings UI
	! Made settings backwards compatible with SweetFX

*/

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Preset
// Custom, Monitor or modern TV,  Equal weight,  Agfa 200X,  Agfapan 25,  Agfapan 100,  Agfapan 400,  Ilford Delta 100,  Ilford Delta 400,  Ilford Delta 400 Pro & 3200,  Ilford FP4,  Ilford HP5,  Ilford Pan F,  Ilford SFX,  Ilford XP2 Super,  Kodak Tmax 100,  Kodak Tmax 400,  Kodak Tri-X
//!DEFAULT 0
//!MIN 0
//!MAX 17
//!STEP 1
int Monochrome_preset;

//!PARAMETER
//!LABEL Custom Conversion (Red)
//!DEFAULT 0.21
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Monochrome_conversion_Red;

//!PARAMETER
//!LABEL Custom Conversion (Green)
//!DEFAULT 0.72
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Monochrome_conversion_Green;

//!PARAMETER
//!LABEL Custom Conversion (Blue)
//!DEFAULT 0.07
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Monochrome_conversion_Blue;

//!PARAMETER
//!LABEL Saturation
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Monochrome_color_saturation;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Removes color making everything monochrome.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;

	float3 Coefficients = float3(0.21, 0.72, 0.07);

	float3 Coefficients_array[18] = 
	{
		float3(Monochrome_conversion_Red, Monochrome_conversion_Green, Monochrome_conversion_Blue), //Custom
		float3(0.21, 0.72, 0.07), //sRGB monitor
		float3(0.3333333, 0.3333334, 0.3333333), //Equal weight
		float3(0.18, 0.41, 0.41), //Agfa 200X
		float3(0.25, 0.39, 0.36), //Agfapan 25
		float3(0.21, 0.40, 0.39), //Agfapan 100
		float3(0.20, 0.41, 0.39), //Agfapan 400 
		float3(0.21, 0.42, 0.37), //Ilford Delta 100
		float3(0.22, 0.42, 0.36), //Ilford Delta 400
		float3(0.31, 0.36, 0.33), //Ilford Delta 400 Pro & 3200
		float3(0.28, 0.41, 0.31), //Ilford FP4
		float3(0.23, 0.37, 0.40), //Ilford HP5
		float3(0.33, 0.36, 0.31), //Ilford Pan F
		float3(0.36, 0.31, 0.33), //Ilford SFX
		float3(0.21, 0.42, 0.37), //Ilford XP2 Super
		float3(0.24, 0.37, 0.39), //Kodak Tmax 100
		float3(0.27, 0.36, 0.37), //Kodak Tmax 400
		float3(0.25, 0.35, 0.40) //Kodak Tri-X
	};

	Coefficients = Coefficients_array[Monochrome_preset];

	// Calculate monochrome
	float3 grey = dot(Coefficients, color);

	// Adjust the remaining saturation
	color = lerp(grey, color, Monochrome_color_saturation);

	// Return the result
	return saturate(color);
}