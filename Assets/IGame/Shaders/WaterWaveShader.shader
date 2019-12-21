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
                fixed2 uv = o.uv;

                // 当前点到纹理中心点的距离
                fixed2 duv = fixed2(0.5,0.5) - uv;
                float  dis = sqrt(duv.x*duv.x + duv.y* duy.y);

                fixed4 mainColor = tex2D(_MainTex,o.uv);
                return mainColor;
            }



            ENDCG
        }
    }

    Fallback "Diffuse"
}