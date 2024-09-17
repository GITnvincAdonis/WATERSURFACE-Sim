using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveDisplacementInteraction : MonoBehaviour
{
    [SerializeField] private Material planeData;

   // readonly float[] Amplitudes = new float[4];
   // float[] ZAxisAmplitudes = new float[4];

    //float[] WaveLengths = new float[4];
   // float[] ZAxisWaveLengths = new float[4];
    //float[] Speeds = new float[4];
    //float[] ZAxisSpeeds = new float[4];


    float _Amp1, _Amp2, _Amp3, _Amp4;
    float _BAmp1, _BAmp2, _BAmp3, _BAmp4;

    float _WLength1, _WLength2, _WLength3, _WLength4;
    float _BWLength1, _BWLength2, _BWLength3, _BWLength4;

    float _Speed1, _Speed2, _Speed3, _Speed4;
    float _BSpeed1, _BSpeed2, _BSpeed3, _BSpeed4;

    float _scale;
    float sumOfXDisplacement;
    float sumOfDDX;
    float sumOfDDZ;
    float def;

    // Start is called before the first frame update
    void Start()
    {

        _Amp1  = planeData.GetFloat("_Amp1");
        _Amp2 = planeData.GetFloat("_Amp2");
        _Amp3 = planeData.GetFloat("_Amp3"); 
        _Amp4 = planeData.GetFloat("_Amp4");

        _BAmp1 = planeData.GetFloat("_BAmp1");
        _BAmp2 = planeData.GetFloat("_BAmp2");
        _BAmp3 = planeData.GetFloat("_BAmp3"); 
        _BAmp4 = planeData.GetFloat("_BAmp4");

        _WLength1 = planeData.GetFloat("_WLength1");
        _WLength2 = planeData.GetFloat("_WLength2");
        _WLength3 = planeData.GetFloat("_WLength3");
        _WLength4 = planeData.GetFloat("_WLength4");

        _BWLength1 = planeData.GetFloat("_BWLength1"); 
        _BWLength2 = planeData.GetFloat("_BWLength2"); 
        _BWLength3 = planeData.GetFloat("_BWLength3"); 
        _BWLength4 = planeData.GetFloat("_BWLength4");

        _Speed1 = planeData.GetFloat("_Speed1");
        _Speed2 = planeData.GetFloat("_Speed2");
        _Speed3 = planeData.GetFloat("_Speed3");
        _Speed4 = planeData.GetFloat("_Speed4");

        _BSpeed1 = planeData.GetFloat("_BSpeed1");
        _BSpeed2 = planeData.GetFloat("_BSpeed2");
        _BSpeed3 = planeData.GetFloat("_BSpeed3");
        _BSpeed4 = planeData.GetFloat("_BSpeed4");
        _scale = planeData.GetFloat("_scale");






    }

    // Update is called once per frame
    void Update()
    {
        
    
        sumOfXDisplacement = 0f;
        sumOfDDX = 0f;
        sumOfDDZ = 0f;
        float[] Amplitudes = { _Amp1, _Amp2, _Amp3,_Amp4 };
        float[] ZAxisAmplitudes = { _BAmp1,_BAmp2,_BAmp3,_BAmp4 };
        float[] WaveLengths = { _WLength1, _WLength2, _WLength3, _WLength4 };
        float[] ZAxisWaveLengths = { _BWLength1, _BWLength2, _BWLength3, _BWLength4 };
        float[] Speeds = { _Speed1, _Speed2, _Speed3, _Speed4 };
        float[] ZAxisSpeeds= { _BSpeed1, _BSpeed2, _BSpeed3, _BSpeed4 };
        

        for (int i = 0; i < 4; i++){


            /*
                     
                /COMPONENTS OF FUNCTION
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
            float speed = Speeds[i] ;
            float ZAxisSpeed = ZAxisSpeeds[i] ;

            float frequency = (2 / WaveLength);
            float ZAxisfrequency = 2 / ZAxisWaveLength;

            float PhaseConstant = (speed + ZAxisSpeed) * frequency;
            float ZAxisPhaseConstant = ZAxisSpeed * ZAxisfrequency;

           float def = Mathf.Pow(2.71828182845904523f, Mathf.Sin((((frequency * transform.position.x)+ (Time.time* PhaseConstant))+((ZAxisfrequency * transform.position.z) +  (Time.time * ZAxisPhaseConstant)))));
            float Wave = (amplitude + Zamplitude) * def;

           float XDerive = frequency * (amplitude + Zamplitude) * Mathf.Cos((((frequency * transform.position.x) + (Time.time * PhaseConstant)) + ((ZAxisfrequency * transform.position.z) + (Time.time * ZAxisPhaseConstant)))) * def;
           float ZDerive = ZAxisfrequency * (amplitude + Zamplitude) * Mathf.Cos((((frequency * transform.position.x) + (Time.time * PhaseConstant)) + ((ZAxisfrequency * transform.position.z) + (Time.time * ZAxisPhaseConstant)))) * def;

           // Debug.Log(Mathf.Sin((frequency * transform.position.x)));
           // Debug.Log(WaveLengths[i] * _scale);

            

            sumOfDDX += XDerive;
            sumOfDDZ += ZDerive;
            sumOfXDisplacement += Wave;
        }
        Vector3 Tangent = new Vector3(1, 0, sumOfDDX);
        Vector3 BiNormal = new Vector3(0, 1, sumOfDDZ);

        Vector3 Normal = Vector3.Cross(Tangent, BiNormal);






        //
        transform.rotation = GetAngleDif(Normal);
        transform.position = new Vector3(transform.position.x, sumOfXDisplacement, transform.position.z);
        







    }

    private Quaternion GetAngleDif(Vector3 tanVector)
       // rotation = Quaternion.RotateTowards(transform.rotation, rotation,4);
        //float angle = rotation.eulerAngles.z;
        //Debug.Log(angle);
        // ApplicationMemoryUsageChange current rotation to normalized vector using Quaternion.FromToRotation
        // return eulerangles.z
    {
        //normalize
        tanVector.Normalize();
        Quaternion rotation = Quaternion.FromToRotation(Vector3.forward, tanVector);
        return rotation;
    }

}
