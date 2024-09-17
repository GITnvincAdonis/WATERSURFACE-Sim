Shader "Unlit/DIsplacement"
{
    Properties
    {
        _Amp1("Amp 1", Range(0.000001,10)) = 0.000001
        _Amp2("Amp 2", Range(0.000001,10)) = 0.000001
        _Amp3("Amp 3", Range(0.000001, 10)) = 0.000001
        _Amp4("Amp 4", Range(0.000001, 10)) = 0.000001

         _BAmp1("Second Amp 1", Range(0.000001,10)) = 0.000001
         _BAmp2("Second Amp 2", Range(0.000001,10)) = 0.000001
         _BAmp3("Second Amp 3", Range(0.000001,10)) = 0.000001
         _BAmp4("Second Amp 4", Range(0.000001,10)) = 0.000001

         _WLength1("WaveLen 1", Range(0.001,0.3)) = 0.1
         _WLength2("WaveLen 2", Range(0.001,0.3)) = 0.1
         _WLength3("WaveLen 3", Range(0.001,0.3)) = 0.1
         _WLength4("WaveLen 4", Range(0.001,0.3)) = 0.1

         _BWLength1("Second WaveLen 1", Range(0.001,0.3)) = 0.1
         _BWLength2("Second WaveLen 2", Range(0.001,0.3)) = 0.1
         _BWLength3("Second WaveLen 3", Range(0.001,0.3)) = 0.1
         _BWLength4("Second WaveLen 4", Range(0.001,0.3)) = 0.1

         _Speed1("Speed 1", Range(0.01,50)) = 1
         _Speed2("Speed 2", Range(0.01,50)) = 1
         _Speed3("Speed 3", Range(0.01,50)) = 1
         _Speed4("Speed 4",Range(0.01,05)) = 1

         

        _BSpeed1("Second Speed 1",Range(0.01,50)) = 1
        _BSpeed2("Second Speed 2",Range(0.01,50)) = 1
         _BSpeed3("Second Speed 3", Range(0.01,50)) = 1
         _BSpeed4("Second Speed 4", Range(0.01,50)) = 1
        _specularIntensity("specular Intensity", float) = 1
         _BaseColor("Water Colour", Color) = (1,1,1,1)
        HeightDebug("height ", float) =0
         _scale("Scale", float) = 1
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #define TAU 6.283185307179586
            #define Euler 2.71828182845904523



            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct SecondMeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD;
                float4 vertex : SV_POSITION;
                float3 Normal : TEXCOORD1;


                float TangentData : TEXCOORD2;
                float BinormalData : TEXCOORD3;
                float wPos : TEXCOORD4;
            };

     
            float _Amp1,_Amp2,_Amp3,_Amp4;
            float _BAmp1, _BAmp2, _BAmp3, _BAmp4;

            float _WLength1, _WLength2, _WLength3, _WLength4;
            float _BWLength1, _BWLength2, _BWLength3, _BWLength4;

            float _Speed1, _Speed2, _Speed3, _Speed4;
            float _BSpeed1, _BSpeed2, _BSpeed3, _BSpeed4;

            float _specularExponent;
            float sumOfXDisplacement;
            float sumOfDDX;
            float sumOfDDZ;

            float _specularIntensity;
            float4 _BaseColor;
            float _scale;
            float HeightDebug;

            Interpolators vert(MeshData v, SecondMeshData Wv)
            {
                Interpolators o;


                float3 WorldPos = mul(UNITY_MATRIX_M,v.vertex);

                float Amplitudes[4] = { _Amp1,_Amp2,_Amp3,_Amp4 };
                float ZAxisAmplitudes[4] = { _BAmp1,_BAmp2,_BAmp3,_BAmp4 };

                float WaveLengths[4] = { _WLength1, _WLength2, _WLength3, _WLength4 };
                float ZAxisWaveLengths[4] = { _BWLength1, _BWLength2, _BWLength3, _BWLength4 };

                float Speeds[4] = { _Speed1, _Speed2, _Speed3, _Speed4 };
                float ZAxisSpeeds[4] = { _BSpeed1, _BSpeed2, _BSpeed3, _BSpeed4 };

                for (int i = 0; i < 4; i++) {


                    /**/ //COMPONENTS OF FUNCTION
                    /*

                    w*e^(sin(freq*x + time*freq*speed  + freq2z + time*freq2*speed))

                    w = sum of amplitudes
                    e = euler's constant
                    freq(a) = 2/ wavelength
                    phase constant(b) = freq * speed
                    x and z = Positional inputs

                    =====>
                    w*e^(sin((a*x + time*b) + (a2z + time*b2)))
                    */
                    float amplitude = Amplitudes[i];
                    float Zamplitude = ZAxisAmplitudes[i];

                    float WaveLength = WaveLengths[i] * _scale;
                    float ZAxisWaveLength = ZAxisWaveLengths[i] * _scale;

                    float speed = Speeds[i];
                    float ZAxisSpeed = ZAxisSpeeds[i];

                    float frequency = (2 / WaveLength);
                    float ZAxisfrequency = 2 / ZAxisWaveLength;

                    float PhaseConstant = (speed + ZAxisSpeed) * frequency;
                    float ZAxisPhaseConstant = ZAxisSpeed * ZAxisfrequency;

                    float def = pow(Euler, sin((((frequency * WorldPos.x)+ (_Time.y * PhaseConstant))+((ZAxisfrequency * WorldPos.z) +  (_Time.y * ZAxisPhaseConstant)))));
                    float Wave = (amplitude + Zamplitude) * def;

                    float XDerive = frequency * (amplitude + Zamplitude) * cos((((frequency * WorldPos.x) + (_Time.y * PhaseConstant)) + ((ZAxisfrequency * WorldPos.z) + (_Time.y * ZAxisPhaseConstant)))) * def;
                    float ZDerive = ZAxisfrequency * (amplitude + Zamplitude) * cos((((frequency * WorldPos.x) + (_Time.y * PhaseConstant)) + ((ZAxisfrequency * WorldPos.z) + (_Time.y * ZAxisPhaseConstant)))) * def;

                    sumOfDDX += XDerive ;
                    sumOfDDZ += ZDerive;
                    sumOfXDisplacement +=  Wave;
                }

                float3 Tangent = float3(1, 0, sumOfDDX );
                float3 BiNormal = float3(0, 1, sumOfDDZ );

                float3 crossProduct = cross(Tangent, BiNormal);


                v.vertex.y = sumOfXDisplacement;
                o.vertex = UnityObjectToClipPos(v.vertex);


                o.wPos = mul(UNITY_MATRIX_M, v.vertex);
                o.Normal = crossProduct;


                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 N = i.Normal;
                float V = normalize(_WorldSpaceCameraPos - i.wPos);

                float H = normalize(V + L);

                float SpecularHighlight = pow(saturate(dot(H, N)),_specularIntensity);
                float Lambert = saturate(dot(L, (N.z + N.x + N.y)));
                // sample the texture
                float4 PrincipleSurfaceDisplay = (Lambert * _BaseColor) + SpecularHighlight;
                return float4(PrincipleSurfaceDisplay);
                //return float4(1,1,1, 1);
            }
            ENDCG
        }
    }
}
