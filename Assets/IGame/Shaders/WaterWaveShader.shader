// 模拟屏幕水波纹效果
Shader "IGameShaderReview/WaterWaveShader"
{
    Properties
    {
        _MainTex("Main RGB", 2D) = "white"{}
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }

        pass
        {
            Tags
            {
                "LightModel" = "ForwardBase"
            }

            CGPROGRAM
            // ZWrite Off 
            #include "UnityCG.cginc"

            #pragma vertex vertShader 
            #pragma fragment fragShader 

            sampler2D _MainTex;
            float4    _MainTex_ST;

            float _distanceFactor;
            float _timeFactor;
            float _totalFactor;
            float _waveWidth;
            float _curWaveDis;

            struct a2v 
            {
                float4 vertex:POSITION;
                half2  texcoord:TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vertShader(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 fragShader(v2f o):SV_TARGET
            {
                // 当前点到纹理中心点的距离
                fixed2 dv = fixed2(0.5,0.5) - o.uv;;
                // 处理屏幕的长宽比
                dv *= float2(_ScreenParams.x/_ScreenParams.y,1.0);
                float  dis = sqrt(dv.x*dv.x + dv.y* dv.y);

                float sinFactor = sin(dis*_distanceFactor + _Time.y*_timeFactor)*_totalFactor*0.01;
                float discardFactor = clamp(_waveWidth - abs(_curWaveDis - dis),0,1);

                //归一化
                float2 dv1 = normalize(dv);
                //计算每个像素uv的偏移值
                float2 offset = dv1  * sinFactor * discardFactor;
                //像素采样时偏移offset
                float2 uv = offset + o.uv;
                return tex2D(_MainTex, uv);
            }



            ENDCG
        }
    }

    Fallback Off 
}