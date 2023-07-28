/*
    Description : PD80 01 HQ Bloom for Reshade https://reshade.me/
    Author      : prod80 (Bas Veth)
    License     : MIT, Copyright (c) 2020 prod80

    Additional credits (exposure)
    - Padraic Hennessy for the logic
      https://placeholderart.wordpress.com/2014/11/21/implementing-a-physically-based-camera-manual-exposure/
    - Padraic Hennessy for the logic
      https://placeholderart.wordpress.com/2014/12/15/implementing-a-physically-based-camera-automatic-exposure/
    - MJP and David Neubelt for the method
      https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/Exposure.hlsl
      License: MIT, Copyright (c) 2016 MJP

    MIT License
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    
*/

// TODO:
// * Restore Focus Bloom options
// * Restore Chromatic Aberration options
// * Restore quality options (currently hardcoded to High)

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT
//!USE_DYNAMIC

//!PARAMETER
//!LABEL Bloom debug
//!DEFAULT 0
//!MIN 0
//!MAX 1
//!STEP 1
int debugBloom;

// Magpie always lists bool parameters at the top, so Kelvin controls were moved up to stick together

//!PARAMETER
//!LABEL Enable Bloom Color Temp (K)
//!DEFAULT 0
//!MIN 0
//!MAX 1
//!STEP 1
int enableBKelvin;

//!PARAMETER
//!LABEL Bloom Color Temp (K)
//!DEFAULT 6500
//!MIN 1000
//!MAX 40000
//!STEP 1
int BKelvin;

// Magpie does not give time nor frametime, and so we need monitor refresh rate to calculate time

//!PARAMETER
//!LABEL Monitor Refresh Rate
//!DEFAULT 60.0
//!MIN 30.0
//!MAX 240.0
//!STEP 1.0
float FPS;

//!PARAMETER
//!LABEL Bloom Dither Stength
//!DEFAULT 2.0
//!MIN 0.0
//!MAX 10.0
//!STEP 0.1
float dither_strength;

//!PARAMETER
//!LABEL Bloom Mix
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float BloomMix;

//!PARAMETER
//!LABEL Bloom Threshold
//!DEFAULT 0.33
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float BloomLimit;

//!PARAMETER
//!LABEL Bloom Exposure 50% Greyvalue
//!DEFAULT 0.33
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float GreyValue;

//!PARAMETER
//!LABEL Bloom Exposure
//!DEFAULT 0.0
//!MIN -1.0
//!MAX 5.0
//!STEP 0.01
float bExposure;

//!PARAMETER
//!LABEL Bloom Width
//!DEFAULT 30.0
//!MIN 10.0
//!MAX 300.0
//!STEP 1.00
float BlurSigma;

//!PARAMETER
//!LABEL Bloom Add Saturation
//!DEFAULT 0.0
//!MIN 0.0
//!MAX 2.0
//!STEP 0.01
float BloomSaturation;

//!TEXTURE
Texture2D INPUT;

// Magpie does not generate mipmaps, so I have to shrink manually to find average Luma

//!TEXTURE
//!WIDTH 256
//!HEIGHT 256
//!FORMAT R16_FLOAT
// MipLevel = 0
Texture2D texBLuma;

//!TEXTURE
//!WIDTH 128
//!HEIGHT 128
//!FORMAT R16_FLOAT
// MipLevel = 1
Texture2D texBLuma1;

//!TEXTURE
//!WIDTH 64
//!HEIGHT 64
//!FORMAT R16_FLOAT
// MipLevel = 2
Texture2D texBLuma2;

//!TEXTURE
//!WIDTH 32
//!HEIGHT 32
//!FORMAT R16_FLOAT
// MipLevel = 3
Texture2D texBLuma3;

//!TEXTURE
//!WIDTH 16
//!HEIGHT 16
//!FORMAT R16_FLOAT
// MipLevel = 4
Texture2D texBLuma4;

//!TEXTURE
//!WIDTH 4
//!HEIGHT 4
//!FORMAT R16_FLOAT
// MipLevel = 5
Texture2D texBLuma5;

//!TEXTURE
//!WIDTH 1
//!HEIGHT 1
//!FORMAT R16_FLOAT
Texture2D texBAvgLuma;

//!TEXTURE
//!WIDTH 1
//!HEIGHT 1
//!FORMAT R16_FLOAT
Texture2D texBPrevAvgLuma;

//!TEXTURE
//!WIDTH INPUT_WIDTH / 2
//!HEIGHT INPUT_HEIGHT / 2
//!FORMAT R16G16B16A16_FLOAT
Texture2D texBloomIn;

//!TEXTURE
//!WIDTH INPUT_WIDTH / 2
//!HEIGHT INPUT_HEIGHT / 2
//!FORMAT R16G16B16A16_FLOAT
Texture2D texBloomH;

//!TEXTURE
//!WIDTH INPUT_WIDTH / 2
//!HEIGHT INPUT_HEIGHT / 2
//!FORMAT R16G16B16A16_FLOAT
Texture2D texBloom;

//!TEXTURE
//!SOURCE pd80_bluenoise_rgba.png
Texture2D texNoiseRGB;

//!SAMPLER
//!FILTER LINEAR
//!ADDRESS CLAMP
SamplerState SampleLinear;

//!SAMPLER
//!FILTER POINT
//!ADDRESS CLAMP
SamplerState SamplePoint;

//!SAMPLER
//!FILTER POINT
//!ADDRESS WRAP
SamplerState SamplePointWrap;

//!COMMON

// Hard code values for now
#define BLOOM_ENABLE_CA         0
#define BLOOM_QUALITY_0_TO_2	1
#define BLOOM_LOOPCOUNT         300
#define BLOOM_LIMITER           0.0001
#define BLOOM_USE_FOCUS_BLOOM   0
#define BLOOM_MIPLVL            1

#define LumCoeff float3(0.212656, 0.715158, 0.072186)
#define PI 3.141592f

float getLuminance( in float3 x )
{
    return dot( x, LumCoeff );
}

// Magpie cannot have pass after output pass, so have to move this to the start

//!PASS 1
//!DESC PS_PrevAvgBLuma
//!STYLE PS
//!IN texBAvgLuma
//!OUT texBPrevAvgLuma
float Pass1(float2 texcoord) {
    float avgLuma    = texBAvgLuma.SampleLevel(SampleLinear, float2( 0.5f, 0.5f ), 0).x;
    return avgLuma;
}


//!PASS 2
//!DESC PS_WriteBLuma
//!STYLE PS
//!IN INPUT
//!OUT texBLuma

float3 SRGBToLinear( float3 color )
{
    float3 x = color / 12.92f;
    float3 y = pow(max((color + 0.055f) / 1.055f, 0.0f), 2.4f);

    float3 clr = color;
    clr.r = color.r <= 0.04045f ? x.r : y.r;
    clr.g = color.g <= 0.04045f ? x.g : y.g;
    clr.b = color.b <= 0.04045f ? x.b : y.b;

    return clr;
}

float Pass2(float2 texcoord) {
    float4 color     = INPUT.SampleLevel(SampleLinear, texcoord, 0);
    color.rgb        = SRGBToLinear(color.rgb);
    float luma       = getLuminance( color.xyz );
    luma             = max( luma, BloomLimit ); // Bloom threshold
    return log2( luma );
}

// Magpie does not generate mipmaps, so I have to shrink manually to find average Luma

//!PASS 3
//!DESC texBLuma1
//!STYLE PS
//!IN texBLuma
//!OUT texBLuma1
float Pass3(float2 texcoord) {
    return texBLuma.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 4
//!DESC texBLuma2
//!STYLE PS
//!IN texBLuma1
//!OUT texBLuma2
float Pass4(float2 texcoord) {
    return texBLuma1.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 5
//!DESC texBLuma3
//!STYLE PS
//!IN texBLuma2
//!OUT texBLuma3
float Pass5(float2 texcoord) {
    return texBLuma2.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 6
//!DESC texBLuma4
//!STYLE PS
//!IN texBLuma3
//!OUT texBLuma4
float Pass6(float2 texcoord) {
    return texBLuma3.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 7
//!DESC texBLuma5
//!STYLE PS
//!IN texBLuma4
//!OUT texBLuma5
float Pass7(float2 texcoord) {
    return texBLuma4.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 8
//!DESC PS_AvgBLuma
//!STYLE PS
//!IN texBLuma5, texBPrevAvgLuma
//!OUT texBAvgLuma
float Pass8(float2 texcoord) {
    float luma       = texBLuma5.SampleLevel(SampleLinear, float2(0.5f, 0.5f), 8).x;
    luma             = exp2( luma );
    // Magpie does not give time or frametime, so I have to hardcode this to some framerate
    float prevluma   = texBPrevAvgLuma.SampleLevel(SamplePoint, float2(0.5f, 0.5f), 0).x;
    float avgLuma    = lerp( prevluma, luma, 2.0 * rcp(FPS)); 
    return avgLuma;
}

//!PASS 9
//!DESC PS_BloomIn
//!STYLE PS
//!IN INPUT, texBAvgLuma
//!OUT texBloomIn

float Log2Exposure( in float avgLuminance, in float GreyValue )
{
    float exposure   = 0.0f;
    avgLuminance     = max(avgLuminance, 0.000001f);
    // GreyValue should be 0.148 based on https://placeholderart.wordpress.com/2014/11/21/implementing-a-physically-based-camera-manual-exposure/
    // But more success using higher values >= 0.5
    float linExp     = GreyValue / avgLuminance;
    exposure         = log2( linExp );
    return exposure;
}

float3 CalcExposedColor( in float3 color, in float avgLuminance, in float offset, in float GreyValue )
{
    float exposure   = Log2Exposure( avgLuminance, GreyValue );
    exposure         += offset; //offset = exposure
    return exp2( exposure ) * color;
}

float4 Pass9(float2 texcoord) {
    float4 color     = INPUT.SampleLevel(SampleLinear, texcoord, 0);
    float luma       = texBAvgLuma.SampleLevel(SampleLinear, float2( 0.5, 0.5 ), 0).x;
    luma             = clamp( luma, 0.000001f, 0.999999f );
    color.xyz        = saturate( color.xyz - luma ) / saturate( 1.0f - luma );
    color.xyz        = CalcExposedColor( color.xyz, luma, bExposure, GreyValue );
    return float4( color.xyz, 1.0f ); 
}

//!PASS 10
//!DESC PS_GaussianH
//!STYLE PS
//!IN texBloomIn
//!OUT texBloomH
float4 Pass10(float2 texcoord) {
    uint texBloomInWidth, texBloomInHeight;
    texBloomIn.GetDimensions(texBloomInWidth, texBloomInHeight);

    float4 color     = texBloomIn.SampleLevel(SampleLinear, texcoord, 0);
    float px         = rcp(texBloomInWidth);
    float SigmaSum   = 0.0f;
    float pxlOffset  = 1.5f;
    float2 buffSigma = 0.0f;
    #if( BLOOM_QUALITY_0_TO_2 == 0 )
        float bSigma = BlurSigma;
    #elif( BLOOM_QUALITY_0_TO_2 == 1 )
        float bSigma = BlurSigma * 0.5f;
    #else
        float bSigma = BlurSigma * 0.25f;
    #endif
    //Gaussian Math
    float3 Sigma;
    Sigma.x          = 1.0f / ( sqrt( 2.0f * PI ) * bSigma );
    Sigma.y          = exp( -0.5f / ( bSigma * bSigma ));
    Sigma.z          = Sigma.y * Sigma.y;

    //Center Weight
    color.xyz        *= Sigma.x;
    //Adding to total sum of distributed weights
    SigmaSum         += Sigma.x;
    //Setup next weight
    Sigma.xy         *= Sigma.yz;

    [loop]
    for( int i = 0; i < BLOOM_LOOPCOUNT && Sigma.x > BLOOM_LIMITER; ++i )
    {
        buffSigma.x  = Sigma.x * Sigma.y;
        buffSigma.y  = Sigma.x + buffSigma.x;
        color        += texBloomIn.SampleLevel(SampleLinear, (texcoord + float2( pxlOffset * px, 0.0f )), 0) * buffSigma.y;
        color        += texBloomIn.SampleLevel(SampleLinear, (texcoord - float2( pxlOffset * px, 0.0f )), 0) * buffSigma.y;
        SigmaSum     += ( 2.0f * Sigma.x + 2.0f * buffSigma.x );
        pxlOffset    += 2.0f;
        Sigma.xy     *= Sigma.yz;
        Sigma.xy     *= Sigma.yz;
    }

    color            /= SigmaSum;
    return color;
}

//!PASS 11
//!DESC PS_GaussianV
//!STYLE PS
//!IN texBloomH
//!OUT texBloom
float4 Pass11(float2 texcoord) {
    uint texBloomHWidth, texBloomHHeight;
    texBloomH.GetDimensions(texBloomHWidth, texBloomHHeight);
    
    float4 color     = texBloomH.SampleLevel(SampleLinear, texcoord, 0);
    float py         = rcp( texBloomHHeight );
    float SigmaSum   = 0.0f;
    float pxlOffset  = 1.5f;
    float2 buffSigma = 0.0f;
    #if( BLOOM_QUALITY_0_TO_2 == 0 )
        float bSigma = BlurSigma;
    #elif( BLOOM_QUALITY_0_TO_2 == 1 )
        float bSigma = BlurSigma * 0.5f;
    #else
        float bSigma = BlurSigma * 0.25f;
    #endif
    //Gaussian Math
    float3 Sigma;
    Sigma.x          = 1.0f / ( sqrt( 2.0f * PI ) * bSigma );
    Sigma.y          = exp( -0.5f / ( bSigma * bSigma ));
    Sigma.z          = Sigma.y * Sigma.y;

    //Center Weight
    color.xyz        *= Sigma.x;
    //Adding to total sum of distributed weights
    SigmaSum         += Sigma.x;
    //Setup next weight
    Sigma.xy         *= Sigma.yz;

    [loop]
    for( int i = 0; i < BLOOM_LOOPCOUNT && Sigma.x > BLOOM_LIMITER; ++i )
    {
        buffSigma.x  = Sigma.x * Sigma.y;
        buffSigma.y  = Sigma.x + buffSigma.x;
        color        += texBloomH.SampleLevel(SampleLinear, (texcoord + float2( 0.0f, pxlOffset * py )), 0) * buffSigma.y;
        color        += texBloomH.SampleLevel(SampleLinear, (texcoord - float2( 0.0f, pxlOffset * py )), 0) * buffSigma.y;
        SigmaSum     += ( 2.0f * Sigma.x + 2.0f * buffSigma.x );
        pxlOffset    += 2.0f;
        Sigma.xy     *= Sigma.yz;
        Sigma.xy     *= Sigma.yz;
    }

    color            /= SigmaSum;
    return color;
}

//!PASS 12
//!DESC PS_Gaussian
//!STYLE PS
//!IN texBloom, INPUT, texNoiseRGB

float4 dither(float2 coords, int var, bool enabler, float str, bool motion, float swing )
{
    float2 dither_uv = float2(GetOutputSize()) / 512.0;
    float pp = (GetFrameCount() / FPS) % 128.0;

    coords.xy    *= dither_uv.xy;
    float4 noise  = texNoiseRGB.SampleLevel(SamplePointWrap, coords.xy, 0);
    float mot     = motion ? pp + var : 0.0f;
    noise         = frac( noise + 0.61803398875f * mot );
    noise         = ( noise * 2.0f - 1.0f ) * swing;
    return ( enabler ) ? noise * ( str / 255.0f ) : float4( 0.0f, 0.0f, 0.0f, 0.0f );
}

float3 screen( in float3 c, in float3 b )
{ 
    return 1.0f - ( 1.0f - c ) * ( 1.0f - b );
}

float3 vib( float3 res, float x )
{
    float4 sat = 0.0f;
    sat.xy = float2( min( min( res.x, res.y ), res.z ), max( max( res.x, res.y ), res.z ));
    sat.z = sat.y - sat.x;
    sat.w = getLuminance( res.xyz );
    return saturate( lerp( sat.w, res.xyz, 1.0f + ( x * ( 1.0f - sat.z ))));
}

float3 HUEToRGB( in float H )
{
    return saturate( float3( abs( H * 6.0f - 3.0f ) - 1.0f,
                                  2.0f - abs( H * 6.0f - 2.0f ),
                                  2.0f - abs( H * 6.0f - 4.0f )));
}

float3 RGBToHCV( in float3 RGB )
{
    // Based on work by Sam Hocevar and Emil Persson
    float4 P         = ( RGB.g < RGB.b ) ? float4( RGB.bg, -1.0f, 2.0f/3.0f ) : float4( RGB.gb, 0.0f, -1.0f/3.0f );
    float4 Q1        = ( RGB.r < P.x ) ? float4( P.xyw, RGB.r ) : float4( RGB.r, P.yzx );
    float C          = Q1.x - min( Q1.w, Q1.y );
    float H          = abs(( Q1.w - Q1.y ) / ( 6.0f * C + 0.000001f ) + Q1.z );
    return float3( H, C, Q1.x );
}

float3 RGBToHSL( in float3 RGB )
{
    RGB.xyz          = max( RGB.xyz, 0.000001f );
    float3 HCV       = RGBToHCV(RGB);
    float L          = HCV.z - HCV.y * 0.5f;
    float S          = HCV.y / ( 1.0f - abs( L * 2.0f - 1.0f ) + 0.000001f);
    return float3( HCV.x, S, L );
}

float3 HSLToRGB( in float3 HSL )
{
    float3 RGB       = HUEToRGB(HSL.x);
    float C          = (1.0f - abs(2.0f * HSL.z - 1.0f)) * HSL.y;
    return ( RGB - 0.5f ) * C + HSL.z;
}

float3 KelvinToRGB( in float k )
{
    float3 ret;
    float kelvin     = clamp( k, 1000.0f, 40000.0f ) / 100.0f;
    if( kelvin <= 66.0f )
    {
        ret.r        = 1.0f;
        ret.g        = saturate( 0.39008157876901960784f * log( kelvin ) - 0.63184144378862745098f );
    }
    else
    {
        float t      = max( kelvin - 60.0f, 0.0f );
        ret.r        = saturate( 1.29293618606274509804f * pow( t, -0.1332047592f ));
        ret.g        = saturate( 1.12989086089529411765f * pow( t, -0.0755148492f ));
    }
    if( kelvin >= 66.0f )
        ret.b        = 1.0f;
    else if( kelvin < 19.0f )
        ret.b        = 0.0f;
    else
        ret.b        = saturate( 0.54320678911019607843f * log( kelvin - 10.0f ) - 1.19625408914f );
    return ret;
}

float4 Pass12(float2 texcoord) {
    // #if( !BLOOM_ENABLE_CA )
    float4 bloom     = texBloom.SampleLevel(SampleLinear, texcoord, 0);
    // #endif
    // #if( BLOOM_ENABLE_CA )
    // float4 bloom     = tex2D( samplerCABloom, texcoord );
    // #endif
    float4 color     = INPUT.SampleLevel(SamplePoint, texcoord, 0);
    // Dither
    float4 dnoise    = dither( texcoord.xy, 0, 1, dither_strength, 1, 2.0f - ( 1.0f - BloomLimit ) );
    float3 steps     = smoothstep( 0.0f, 0.012f, bloom.xyz );
    bloom.xyz        = saturate( bloom.xyz + dnoise.xyz * steps.xyz );

    // #if( BLOOM_ENABLE_CA == 0 )
    if( enableBKelvin == 1)
    {
        float3 K       = KelvinToRGB( BKelvin );
        float3 bLum    = RGBToHSL( bloom.xyz );
        float3 retHSV  = RGBToHSL( bloom.xyz * K.xyz );
        bloom.xyz      = HSLToRGB( float3( retHSV.xy, bLum.z ));
    }
    // #endif
    // Vibrance
    bloom.xyz        = vib( bloom.xyz, BloomSaturation );
    float3 bcolor    = screen( color.xyz, bloom.xyz );
    color.xyz        = lerp( color.xyz, bcolor.xyz, BloomMix );
    color.xyz        = debugBloom == 1 ? bloom.xyz : color.xyz; // render only bloom to screen
    return float4( color.xyz, 1.0f );
}
