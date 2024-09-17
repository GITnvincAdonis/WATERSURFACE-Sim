using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AccessMeshData : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] private Material plane;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float Height = plane.GetFloat("HeightDebug");
        //Debug.Log(Height);

    }
}
