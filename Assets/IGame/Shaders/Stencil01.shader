Shader "igame/Stencil01"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
    }

    SubShader
    {
        Tags {"Queue" = "Geometry+1"}
        Stencil
        {
            Ref 1
            Comp Equal 
        }

        pass 
        {
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert 
            #pragma fragment frag 

            struct appdata_t 
            {
                float4 vertex:POSITION;
                float2 texcoord:TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos:SV_POSITION;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }   

            fixed4 frag(v2f o):SV_TARGET
            {
                return fixed4(0,1,1,1);
            }

            ENDCG
        }
    }
}