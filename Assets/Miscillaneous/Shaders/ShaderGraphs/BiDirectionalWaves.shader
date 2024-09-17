Shader "Unlit/BiDirectionalWaves"
{
    Properties
    {
        _Amp1("Amp 1", float) = 0.1
        _Amp2("Amp 2", float) = 0.1
        _Amp3("Amp 3", float) = 0.1
        _Amp4("Amp 4", float) = 0.1

        _BAmp1("Second Amp 1", float) = 0.1
        _BAmp2("Second Amp 2", float) = 0.1
        _BAmp3("Second Amp 3", float) = 0.1
        _BAmp4("Second Amp 4", float) = 0.1

        _WLength1("WaveLen 1", float) = 0.001
        _WLength2("WaveLen 2", float) = 0.001
        _WLength3("WaveLen 3", float) = 0.001
        _WLength4("WaveLen 4", float) = 0.001

        _BWLength1("Second WaveLen 1", float) = 0.001
        _BWLength2("Second WaveLen 2", float) = 0.001
        _BWLength3("Second WaveLen 3", float) = 0.001
        _BWLength4("Second WaveLen 4", float) = 0.001

        _Speed1("Speed 1", float) = 0.001
        _Speed2("Speed 2", float) = 0.001
        _Speed3("Speed 3", float) = 0.001
        _Speed4("Speed 4", float) = 0.001

        _BSpeed1("Second Speed 1", float) = 0.001
        _BSpeed2("Second Speed 2", float) = 0.001
        _BSpeed3("Second Speed 3", float) = 0.001
        _BSpeed4("Second Speed 4", float) = 0.001


        _specularExponent("SpecHighlight", float) = 0.001






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


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #define TAU 6.283185307179586
            #define Euler 2.71828182845904523
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
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct WorldPosMeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct ObjectShadingMeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float TangentData : TEXCOORD1;
                float BinormalData : TEXCOORD2;
            };

            Interpolators vert(MeshData v,WorldPosMeshData Wv,ObjectShadingMeshData Ov)
            {
                Interpolators o;
                float4 worldPos = mul(UNITY_MATRIX_M, Wv.vertex);
                float3 objectPos = Ov.vertex.xyz;


                float Amplitudes[4] = {_Amp1,_Amp2,_Amp3,_Amp4};
                //float ZAxisAmplitudes[4] = { _BAmp1,_BAmp2,_BAmp3,_BAmp4 };

                float WaveLengths[4] = { _WLength1, _WLength2, _WLength3, _WLength4 };
                float ZAxisWaveLengths[4] = { _BWLength1, _BWLength2, _BWLength3, _BWLength4 };

                float Speeds[4] = { _Speed1, _Speed2, _Speed3, _Speed4 };
                float ZAxisSpeeds[4] = { _BSpeed1, _BSpeed2, _BSpeed3, _BSpeed4 };

                for (int i = 0; i < 4; i++) {

                    //VARIABLE INITIALIZATION
                    float amplitude = Amplitudes[i];

                    float WaveLength = WaveLengths[i];
                    float ZAxisWaveLength = ZAxisWaveLengths[i];

                    float speed = Speeds[i];
                    float ZAxisSpeed = ZAxisSpeeds[i];

                    float frequency = 2 / WaveLength;
                    float ZAxisfrequency = 2 / ZAxisWaveLength;

                    float PhaseConstant = speed * frequency;
                    float ZAxisPhaseConstant = ZAxisSpeed * ZAxisfrequency;



                    //COMPONENTS OF FUNCTION
                    /*

                    w*e^(sin(freq*x + time*freq*speed) + sin(freq2z + time*freq2*speed))

                    w = amplitude
                    e = euler's constant
                    freq(a) = 2/ wavelength
                    phase constant(b) = freq * speed
                    x and z = Positional inputs

                    =====>
                    w*e^(sin(a*x + time*b) + sin(a2z + time*b2))
                    */
                    
                    //float ZAxisDisplacemnt = sin((ZAxisfrequency * worldPos.z) + (_Time * ZAxisPhaseConstant));
                    float XAxisDisplacement = sin((frequency * worldPos.x) + (_Time * PhaseConstant)) - 1;
                    float XDisplacementDefinition = (amplitude)*pow(Euler, XAxisDisplacement);
                    sumOfXDisplacement += XDisplacementDefinition;

                    //float PowerDerive = frequency * cos((frequency * objectPos.x) + (_Time * PhaseConstant));
                    //float WaveDef = (amplitude)*pow(Euler, sin((frequency * objectPos.x) + (_Time * PhaseConstant)) - 1);

                    //sumOfDDX += PowerDerive * XDisplacementDefinition;


                    

                   //float ObjectXAxisDisplacement = sin((frequency * objectPos.x) + (_Time * PhaseConstant));
                    //float ObjectZAxisDisplacemnt = sin((ZAxisfrequency * objectPos.z) + (_Time * ZAxisPhaseConstant));

                    //float ObjectDisplacementDefinition = (amplitude)*pow(Euler, ObjectXAxisDisplacement + ObjectZAxisDisplacemnt);




                   // float deriveOfXPower = frequency *cos((frequency * objectPos.x) + (_Time * PhaseConstant));
                    //sumOfDDX += deriveOfXPower * ObjectDisplacementDefinition;
//
                    //float deriveOfZPower = ZAxisfrequency *cos((ZAxisfrequency * objectPos.z) + (_Time * ZAxisPhaseConstant));
                    //sumOfDDZ += deriveOfZPower * ObjectDisplacementDefinition;







                }
                //Displacement
                v.vertex.y = sumOfXDisplacement;
               // o.TangentData = sumOfDDX;
               // o.BinormalData = sumOfDDZ;
                o.vertex = worldPos;
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {

                // float3 TangentVector = float3(1,0,i.TangentData);
                 //float3 BinormalVector = float3(0,1,i.BinormalData);
                 

                 //float3 Normal = (cross(TangentVector, BinormalVector));
                //float3 LightDir = _WorldSpaceLightPos0.xyz;
                //float3 Normal = float3(1,1,i.TangentData);
               

                //float3 LambertianDiffuse = saturate(dot(Normal, LightDir));
                //LambertianDiffuse = pow(LambertianDiffuse,S;//* ;
                return float4(1, 1, 1, 1);
                //return float4(LambertianDiffuse,0);
            }
            ENDCG
        }
    }
}
