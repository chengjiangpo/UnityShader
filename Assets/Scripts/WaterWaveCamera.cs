
#region "模拟屏幕水波效果"
#endregion

using System.Text.RegularExpressions;
using System.Runtime.InteropServices;
using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

[ExecuteInEditMode]
public class WaterWaveCamera : MonoBehaviour
{
    private Material _material;
    //距离系数
    public float distanceFactor = 60.0f;
    //时间系数
    public float timeFactor = -30.0f;
    //sin函数结果系数
    public float totalFactor = 1.0f;
 
    //波纹宽度
    public float waveWidth = 0.3f;
    //波纹扩散的速度
    public float waveSpeed = 0.3f;
 
    private float waveStartTime;

    [Range(0,1)]
    public float maxDistance = 1;

    private void OnEnable() {
        //设置startTime
        waveStartTime = Time.time;

        Shader shader = Shader.Find("IGameShaderReview/WaterWaveShader");
        if (shader != null)
        {
            _material = new Material(shader);
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if (_material != null)
        {
             //计算波纹移动的距离，根据enable到目前的时间*速度求解
            float curWaveDistance = (Time.time - waveStartTime) * waveSpeed;
            curWaveDistance = curWaveDistance%maxDistance;
            //设置一系列参数
            _material.SetFloat("_distanceFactor", distanceFactor);
            _material.SetFloat("_timeFactor", timeFactor);
            _material.SetFloat("_totalFactor", totalFactor);
            _material.SetFloat("_waveWidth", waveWidth);
            _material.SetFloat("_curWaveDis", curWaveDistance);
            Graphics.Blit(src,dest,_material);
        }else 
        {
            Graphics.Blit(src,dest);
        }
    }
}