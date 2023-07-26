/**
 * FilmGrain version 1.0
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 *
 * Ported to Magpie by Eric Banker ~ Kourinn
 *
 * Computes a noise pattern and blends it with the image to create a film grain look.
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT
//!USE_DYNAMIC

//!PARAMETER
//!LABEL Intensity
// How visible the grain is. Higher is more visible.
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Intensity;

//!PARAMETER
//!LABEL Variance
// Controls the variance of the Gaussian noise. Lower values look smoother.
//!DEFAULT 0.4
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Variance;

//!PARAMETER
//!LABEL Mean
// Affects the brightness of the noise.
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Mean;

//!PARAMETER
//!LABEL Signal-to-Noise Ratio
// Higher Signal-to-Noise Ratio values give less grain to brighter pixels. 0 disables this feature.
//!DEFAULT 6
//!MIN 0
//!MAX 16
//!STEP 1
int SignalToNoiseRatio;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Computes a noise pattern and blends it with the image to create a film grain look.
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 texcoord) {
	float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
  
	//float inv_luma = dot(color, float3(-0.2126, -0.7152, -0.0722)) + 1.0;
	float inv_luma = dot(color, float3(-1.0/3.0, -1.0/3.0, -1.0/3.0)) + 1.0; //Calculate the inverted luma so it can be used later to control the variance of the grain
  
	/*---------------------.
	| :: Generate Grain :: |
	'---------------------*/

	const float PI = 3.1415927;
	
	//time counter using requested counter from ReShade
	// Magpie only has frame count, not elapsed time in milliseconds, so I rescaled this for frametime at 60 fps
	float t = GetFrameCount() * 0.03722833;
	
	//PRNG 2D - create two uniform noise values and save one DP2ADD
	float seed = dot(texcoord, float2(12.9898, 78.233));// + t;
	float sine = sin(seed);
	float cosine = cos(seed);
	float uniform_noise1 = frac(sine * 43758.5453 + t); //I just salt with t because I can
	float uniform_noise2 = frac(cosine * 53758.5453 - t); // and it doesn't cost any extra ASM

	//Get settings
	float stn = SignalToNoiseRatio != 0 ? pow(abs(inv_luma), float(SignalToNoiseRatio)) : 1.0; // Signal to noise feature - Brighter pixels get less noise.
	float variance = (Variance*Variance) * stn;
	float mean = Mean;

	//Box-Muller transform
	uniform_noise1 = (uniform_noise1 < 0.0001) ? 0.0001 : uniform_noise1; //fix log(0)
		
	float r = sqrt(-log(uniform_noise1));
	r = (uniform_noise1 < 0.0001) ? PI : r; //fix log(0) - PI happened to be the right answer for uniform_noise == ~ 0.0000517.. Close enough and we can reuse a constant.
	float theta = (2.0 * PI) * uniform_noise2;
	
	float gauss_noise1 = variance * r * cos(theta) + mean;
	//float gauss_noise2 = variance * r * sin(theta) + mean; //we can get two gaussians out of it :)

	//gauss_noise1 = (ddx(gauss_noise1) - ddy(gauss_noise1)) * 0.50  + gauss_noise2;
  

	//Calculate how big the shift should be
	//float grain = lerp(1.0 - Intensity,  1.0 + Intensity, gauss_noise1);
	float grain = lerp(1.0 + Intensity,  1.0 - Intensity, gauss_noise1);
  
	//float grain2 = (2.0 * Intensity) * gauss_noise1 + (1.0 - Intensity);
	 
	//Apply grain
	color = color * grain;
  
	//color = (grain-1.0) *2.0 + 0.5;
  
	//color = lerp(color,colorInput.rgb,sqrt(luma));

	/*-------------------------.
	| :: Debugging features :: |
	'-------------------------*/

	//color.rgb = frac(gauss_noise1).xxx; //show the noise
	//color.rgb = (gauss_noise1 > 0.999) ? float3(1.0,1.0,0.0) : 0.0 ; //does it reach 1.0?
	
	return color.rgb;
}
