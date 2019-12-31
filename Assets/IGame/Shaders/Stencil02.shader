Shader "igame/Stencil02"
{
    Properties
    {
        _MainTex("Main Texture",2D) = "blue" {}
    }

    SubShader
    {
        Tags{"Queue" = "Geometry"}
        Stencil
        {
            Ref 1
            Comp Always 
            Pass Replace
        }

        Pass 
        {
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;
            float4    _MainTex_ST;

            struct appdata_t 
            {
                float4 vertex:POSITION;
                float2 texcoord:TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_TEX(v.texcoord,_MainTex);

                return o;
            }

            fixed4 frag(v2f o):SV_TARGET
            {
                fixed4 color = tex2D(_MainTex,o.uv);

                return color;
            }

            ENDCG
        }
    }
}