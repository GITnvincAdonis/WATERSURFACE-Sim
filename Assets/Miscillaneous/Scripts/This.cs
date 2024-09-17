using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class This : MonoBehaviour
{
    private Mesh mesh;
    private Vector3[] originalVertices;
    public float displacementAmount = 0.1f;
    // Start is called before the first frame update
    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;
        originalVertices = mesh.vertices;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3[] vertices = mesh.vertices;

        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i] = originalVertices[i] + Vector3.up * Mathf.Sin(Time.time) * displacementAmount;
        }

        mesh.vertices = vertices;
        mesh.RecalculateBounds();
        Debug.Log("yello");
    }
    

    

 

    
}
