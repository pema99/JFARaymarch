//

Shader "Pema99/JFA/JFADistance"
{
    Properties
    {
        _MainTex ("Previous Pass Tex", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "JFACommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            Texture2D _MainTex;
            int _Pass;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 frag (v2f i) : SV_Target
            {
                // Calculate [0; 1] coordinate in volume of current fragment
                uint2 texCoord = i.uv * texSize;
                float3 volCoord = TexToVol(texCoord) + 0.5;
                float3 volUV = volCoord / float(volSize);

                // Calculate distance to pos in texture
                return distance(volUV, _MainTex[texCoord]);
            }
            ENDCG
        }
    }
}
