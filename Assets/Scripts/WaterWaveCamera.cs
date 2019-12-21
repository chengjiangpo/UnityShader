
#region "模拟屏幕水波效果"
#endregion

using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

[ExecuteInEditMode]
public class WaterWaveCamera : MonoBehaviour
{
    private Material _material;
    private void OnEnable() {
        Shader shader = Shader.Find("IGameShaderReview/WaterWaveShader");
        if (shader != null)
        {
            _material = new Material(shader);
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if (_material != null)
        {
            Graphics.Blit(src,dest,_material);
        }else 
        {
            Graphics.Blit(src,dest);
        }
    }
}