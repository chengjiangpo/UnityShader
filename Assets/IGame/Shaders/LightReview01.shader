Shader "IGameShaderReview/LightReview01"
{
    Properties
    {
        _MainTex("MainTexture",2d) = "white"{}
        _Diffuse("Diffuse Color", Color) = (1,1,1,1)
        _Specular("Specular Color", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8,256)) = 18
        _HalfLambart("use Half-Lambart",Int) = 1
        _BlinnPhong("use Blinn-Phong",Int) = 1
    }

    SubShader
    {
        pass 
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase

            #pragma vertex      vertShader 
            #pragma fragment    fragShader

            sampler2D _MainTex;
            float4    _MainTex_ST;

            fixed4    _Diffuse;
            fixed4    _Specular;
            fixed     _Gloss;

            int       _HalfLambart;
            int       _BlinnPhong;

            struct A2V
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                half2  texcoord:TEXCOORD0;
            };

            struct V2F
            {
                float4 pos:SV_POSITION;
                half2  uv:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos   :TEXCOORD2;
                SHADOW_COORDS(3)
            };

            V2F vertShader(A2V v)
            {
                V2F o;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos    = WorldSpaceViewDir(v.vertex);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 fragShader(V2F i):SV_TARGET
            {
                fixed4 mainColor = tex2D(_MainTex,i.uv);

                // 计算光线的方向(需要处理非平行光的情况)
                float3 lightDir = normalize(_WorldSpaceLightPos0);

                // 环境光的计算(环境光叠加到当前的纹理上)
                fixed4 ambientColor = UNITY_LIGHTMODEL_AMBIENT * mainColor;

                // 漫反射计算(通过入射光线和法线的点乘的结果作为漫反射的反射强度，结果叠加到_LightColor0上，注意：全部基于世界坐标系)
                 fixed4 diffuseColor = fixed4(0,0,0,1);
                if (_HalfLambart == 1)
                {
                    diffuseColor = _LightColor0 * _Diffuse * (dot(i.worldNormal,lightDir)*0.5 + 0.5);
                }else 
                {
                    diffuseColor = _LightColor0 * _Diffuse * saturate(dot(i.worldNormal,lightDir));
                }
                

                /*
                 *  高光反射: 
                 *      1、通过入射光线和法线获取到反射光线的方向
                 *      2、获取当前点到摄像机之间的方向向量
                 *      3、反射光线和视线向量点乘并取N(高光系数)次方实现高光效果
                 *      结果叠加到_LightColor0上
                 */
                fixed3 viewDir    = normalize(i.worldPos);
                fixed4 specularColor = fixed4(0,0,0,1);
                 
                if(_BlinnPhong == 1)
                {
                    // Blinn-Phong高光反射
                    fixed3 halfDir = normalize(lightDir + viewDir);
                    specularColor = _LightColor0 * _Specular *pow(saturate(dot(i.worldNormal,halfDir)),_Gloss);
                }else 
                {
                    // Phong高光反射
                    fixed3 reflectDir = normalize(reflect(-lightDir,i.worldNormal));
                    specularColor = _LightColor0 * _Specular *pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                }

                fixed shadow = SHADOW_ATTENUATION(i);
                
                return ambientColor + (diffuseColor + specularColor)*shadow;
            }

            ENDCG
        }

        pass 
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            BlendOp Add
            Blend One One

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Autolight.cginc" 
            #include "UnityPBSLighting.cginc"
            
            #pragma multi_compile_fwdadd
            // #pragma multi_compile_shadowcaster

            #pragma vertex      vertShader 
            #pragma fragment    fragShader


            sampler2D _MainTex;
            float4    _MainTex_ST;

            fixed4    _Diffuse;
            fixed4    _Specular;
            fixed     _Gloss;

            int       _HalfLambart;
            int       _BlinnPhong;

            struct A2V
            {
                float4 vertex:POSITION;
                half2  texcoord:TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct V2F
            {
                float4 pos:SV_POSITION;
                half2  uv:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos   :TEXCOORD2;
                float3 lightDir   :TEXCOORD3;
            };

            V2F vertShader(A2V v)
            {
                V2F o;
                o.pos         = UnityObjectToClipPos(v.vertex);
                o.uv          = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos    = WorldSpaceViewDir(v.vertex);
                o.lightDir    = WorldSpaceLightDir(v.vertex);
                return o;
            }

            fixed4 fragShader(V2F o):SV_TARGET
            {
                fixed4 mainColor = tex2D(_MainTex,o.uv);

                // 计算光线的方向(需要处理非平行光的情况)
                float3 lightDir = normalize(o.lightDir);

                // 漫反射计算(通过入射光线和法线的点乘的结果作为漫反射的反射强度，结果叠加到_LightColor0上，注意：全部基于世界坐标系)
                 fixed4 diffuseColor = fixed4(0,0,0,1);
                if (_HalfLambart == 1)
                {
                    diffuseColor = _LightColor0 * _Diffuse * (dot(o.worldNormal,lightDir)*0.5 + 0.5);
                }else 
                {
                    diffuseColor = _LightColor0 * _Diffuse * saturate(dot(o.worldNormal,lightDir));
                }
                
                
                /*
                 *  高光反射: 
                 *      1、通过入射光线和法线获取到反射光线的方向
                 *      2、获取当前点到摄像机之间的方向向量
                 *      3、反射光线和视线向量点乘并取N(高光系数)次方实现高光效果
                 *      结果叠加到_LightColor0上
                 */
                fixed3 viewDir    = normalize(o.worldPos);
                fixed4 specularColor = fixed4(0,0,0,1);
                 
                if(_BlinnPhong == 1)
                {
                    // Blinn-Phong高光反射
                    fixed3 halfDir = normalize(lightDir + viewDir);
                    specularColor = _LightColor0 * _Specular *pow(saturate(dot(o.worldNormal,halfDir)),_Gloss);
                }else 
                {
                    // Phong高光反射
                    fixed3 reflectDir = normalize(reflect(-lightDir,o.worldNormal));
                    specularColor = _LightColor0 * _Specular *pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                }
                
                // 计算光照衰减
                UNITY_LIGHT_ATTENUATION(atten, 0, fixed3(0,0,0));
                return (diffuseColor + specularColor)* atten;
            }

            ENDCG
        }

        // ShadowCaster(Unity内部的实现方式)
        pass
        {
            Name "ShadowCaster"    
            Tags {"LightMode" = "ShadowCaster"} 

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #pragma multi_compile_shadowcaster 
            #include "UnityCG.cginc"

            struct v2f 
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                SHADOW_CASTER_FRAGMENT(I);
            }

            ENDCG
        }
    }

    // Fallback "Specular"
}