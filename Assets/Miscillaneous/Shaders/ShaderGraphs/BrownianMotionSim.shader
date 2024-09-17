Shader "Unlit/BrownianMotionSim"
{
    Properties
        {
        

            _seed("seed", Range(0.01,100000)) = 2
            _seedIter("seed Iterator", Range(1,2000)) = 2
            _MaxSpeed("Max speed", Range(0.01,2)) = 2
            _speedRamp("speed Ramp Value", Range(0.001,2)) = .001

            _frequency("frequency", Range(0,4)) = 1
            _frequencyMult("frequency multiplier", Range(0.001,5)) = .001
            _amplitude("amplitude", Range(0.01,2)) = 2
            _amplitudeMult("amplitude multiplier", Range(0.001,2)) = .001

        _VertexMaxPeak("Vertex Max Peak", Range(0.01,2)) = 2
        _VertexPeakOffset("Vertex Peak Offset", Range(0.01,2)) = 2
         _vertexHeight("Vertex height", Range(0.01,2)) = 2

        _TipAttenuation("Tip Attenuation", Range(0.01,2)) = 2
       
            
            
            
            _specularIntensity("specular Intensity", float) = 1
            _BaseColor("Water Colour", Color) = (1,1,1,1)
        _TipColor("Tip Color", Color) = (1,1,1,1)
        
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
                    float3 wPos : TEXCOORD4;
                };


        

                float _seed;
                float _seedIter;
                float _speedRamp;
                float _MaxSpeed;
                float _VertexMaxPeak;
                float _VertexPeakOffset;
                float _specularExponent;
                float sumOfXDisplacement;
                float sumOfDDX;
                float sumOfDDZ;
                float _TipAttenuation;
                float _frequency;
                float _frequencyMult;
                float _amplitude;
                float _amplitudeMult;
                float _vertexHeight;

                float _specularIntensity;
                float3 _BaseColor;
                float3 _TipColor;
                float _scale;
   



                
                    // Define a sampler for the skybox texture
                sampler SkyboxSampler : register(s0);

                // Function to sample the skybox texture
                float4 SampleSkyboxTexture(float3 direction)
                {
                    // Sample the skybox texture using the direction vector
                    return texCUBE(SkyboxSampler, direction);
                }

                // Example usage:
                
                float RandomChoice(float2 uv)
                {
                    // Use fract to get a random value between 0 and 1
                    float randomValue = frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);

                    // Map the random value to either -1 or 1
                    return (randomValue < 0.5) ? -1.0 : 1.0;
                }
                /*

                Interpolators vert(MeshData v, SecondMeshData Wv)
                {
                    Interpolators o;


                    float3 WorldPos = mul(UNITY_MATRIX_M, v.vertex);

                   


                    float Speeds[20] = { _Speed1, _Speed2, _Speed3, _Speed4 ,_Speed5, _Speed6, _Speed7, _Speed8, _Speed9, _Speed10,_Speed11, _Speed12, _Speed13, _Speed14 ,_Speed15, _Speed16, _Speed17, _Speed18, _Speed19, _Speed20 };
                    float ZAxisSpeeds[20] = { _BSpeed1, _BSpeed2, _BSpeed3, _BSpeed4 ,_BSpeed5, _BSpeed6, _BSpeed7, _BSpeed8, _BSpeed9, _BSpeed10,_BSpeed11, _BSpeed12, _BSpeed13, _BSpeed14 ,_BSpeed15, _BSpeed16, _BSpeed17, _BSpeed18, _BSpeed19, _BSpeed20 };
                    float curAmplitudeX = 4.1;
                    float curAmplitudeZ = 4;
                    float curWavelengthX = 1* _scale;
                    float curWavelengthZ = 1* _scale;

                    float frequency = (2 / curWavelengthX);
                    float ZAxisfrequency = 2 / curWavelengthZ;

                    
                    for (int i = 0; i < 20; i++) {
                         //COMPONENTS OF FUNCTION
                        
                        w*e^(sin(freq*x + time*freq*speed  + freq2z + time*freq2*speed))
                        w = sum of amplitudes
                        e = euler's constant
                        freq(a) = 2/ wavelength
                        phase constant(b) = freq * speed
                        x and z = Positional inputs
                        =====>
                        w*e^(sin((a*x + time*b) + (a2z + time*b2)))
                        

                        float d = RandomChoice(float2(1, 1));
                        float d2 = RandomChoice(float2(1.5f, 1.9f));
                        float amplitude = curAmplitudeX;
                        float Zamplitude = curAmplitudeZ;

                        



                        float speed = Speeds[i];
                        float ZAxisSpeed = ZAxisSpeeds[i];
                        
                        float PhaseConstant = speed * frequency * d;
                        float ZAxisPhaseConstant = ZAxisSpeed * ZAxisfrequency * d2;

                        float def = pow(Euler, sin((((d * frequency * (WorldPos.x + XDERIVE)) + (_Time.y * PhaseConstant) + ((d2 * ZAxisfrequency * (WorldPos.z + ZDERIVE)) + (_Time.y * ZAxisPhaseConstant)))))-1);

                        float Wave = ((amplitude + Zamplitude) * .5) * (def);

                        float XDerive = randomDirection * frequency * ((amplitude + Zamplitude)*.5) * (cos((((randomDirection * frequency * (WorldPos.x + XDERIVE))+ (_Time.y * PhaseConstant))+ ((randomDirection2 * ZAxisfrequency * (WorldPos.z + ZDERIVE)) + (_Time.y * ZAxisPhaseConstant))))-1) * def;


                        float ZDerive = randomDirection2 * ZAxisfrequency * ((amplitude + Zamplitude) * .5) * (cos(((
                            (randomDirection * frequency * (WorldPos.x + XDERIVE))
                            + (_Time.y * PhaseConstant))
                            + ((randomDirection2 * ZAxisfrequency * (WorldPos.z + ZDERIVE))
                                + (_Time.y * ZAxisPhaseConstant))))-1) * def;
                        XDERIVE = XDerive;
                        ZDERIVE = ZDerive;
                        amplitude *= 0.85f;
                        Zamplitude *= 0.835f;
                        frequency *= (1.136f );
                        ZAxisfrequency *= (1.131f);

                        sumOfDDX += XDerive;
                        sumOfDDZ += ZDerive;
                        sumOfXDisplacement += Wave;
                    }




                    float3 Tangent = float3(1, sumOfDDX, 0);
                    float3 BiNormal = float3(0, sumOfDDZ, 1);

                    float3 crossProduct = cross(Tangent, BiNormal);

                    v.vertex.y = sumOfXDisplacement;
                    o.Normal = crossProduct;

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.wPos = mul(UNITY_MATRIX_M, v.vertex);

                    return o;
                }
                */
                Interpolators vert(MeshData v, SecondMeshData Wv)
                {
                    Interpolators o;


                    
                    o.wPos = mul(unity_ObjectToWorld, v.vertex);
                    

                    
                    
                    float f = _frequency;
                    float amplitude = _amplitude;
                    float speed = _MaxSpeed;
                    float seed = _seed;
                    float3 augmentedPos = o.wPos;
                    float sumOfAmp = 0.0f;
                    
                    for (int i = 0; i < 64; i++) {
                         //COMPONENTS OF FUNCTION
                       
                        
                     
                      
                   
                        
                        float2 d = normalize(float2(cos(seed), sin(seed)));
       
                      
                        float input = dot(d, augmentedPos.xz) * f + _Time.y * speed;
                        float wave = amplitude * exp(_VertexMaxPeak * sin(input) - _VertexPeakOffset);
                        float dx = _VertexMaxPeak * wave * cos(input);



                        sumOfXDisplacement += wave;

                        augmentedPos.xz += d * -dx * amplitude;
                        sumOfAmp += amplitude;
                        amplitude *= _amplitudeMult;
                        f *= _frequencyMult;
                        speed *= _speedRamp;
                        seed += _seedIter;
                        

                        
                        
                    }





             

                    float3 height = 0.0f;
                    height.y = _vertexHeight * (sumOfXDisplacement/sumOfAmp);
                    float4 newPos = v.vertex + float4(height, 0.0f);
 
                    o.vertex = UnityObjectToClipPos(newPos);
                    o.wPos = mul(UNITY_MATRIX_M, newPos);

                    return o;
                }
                float3 fragmentFBM(float3 v) {

                    float f = _frequency;
                    float a = _amplitude;
                    float speed = _MaxSpeed;
                    float seed = _seed;
                    float3 p = v;

                    float h = 0.0f;
                    float2 n = 0.0f;

                    float amplitudeSum = 0.0f;

                    for (int wi = 0; wi < 64; ++wi) {
                        float2 d = normalize(float2(cos(seed), sin(seed)));

                        float x = dot(d, p.xz) * f + _Time.y * speed;
                        float wave = a * exp(_VertexMaxPeak * sin(x) - _VertexPeakOffset);
                        float2 dw = f * d * (_VertexMaxPeak * wave * cos(x));

                        h += wave;
                        p.xz += -dw * a ;

                        n += dw;

                        

                        amplitudeSum += a;
                        f *= _frequencyMult;
                        a *= _amplitudeMult;
                        speed *= _speedRamp;
                        seed += _seedIter;
                    }

                    float3 output = float3(h, n.x, n.y) / amplitudeSum;
                    output.x *= _vertexHeight;

                    return output;
                }


                float4 frag(Interpolators i) : SV_Target
                {



                    float3 L = _WorldSpaceLightPos0.xyz;
                    float3 N = i.Normal;
                    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);

                    //half way vector
                    float3 sum = V - L;
                    float magnitude = pow((pow(sum.x,2) + pow(sum.y, 2) + pow(sum.z, 2)),.5);
                    float H = normalize((V - L) / magnitude);

                    //obtaining height
                    float3 fbm = fragmentFBM(i.wPos);

                    float height = fbm.x;
                    

                    float3 tipColor = _TipColor * pow(height, _TipAttenuation);

                    float3 output = _BaseColor + tipColor;

             

                    return float4(output, 1.0f);
                    

                }
                ENDCG
            }
    }
    }