using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScalarManipulation : MonoBehaviour
{
    [SerializeField] private Material planeData;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        planeData.SetFloat("_scale", transform.localScale.x);
    }
}
