// This shader takes depth textures and generates the seed input for JFA

Shader "Pema99/JFA/JFASeed"
{
    Properties
    {
        _Front ("Front", 2D) = "white"{}
        _Back ("Front", 2D) = "white"{}
        _Left ("Front", 2D) = "white"{}
        _Right ("Front", 2D) = "white"{}
        _Up ("Front", 2D) = "white"{}
        _Down ("Front", 2D) = "white"{}
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

            Texture2D _Front;
            Texture2D _Back;
            Texture2D _Up;
            Texture2D _Down;
            Texture2D _Left;
            Texture2D _Right;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Get coord in volume of current fragment
                uint2 texCoord = i.uv * texSize;
                float3 volCoord = TexToVol(texCoord) + 0.5;

                // Find corresponding depth values from each side of cube
                float f = _Front[volCoord.xy].r;
                float b = _Back[uint2(volSize-1-volCoord.x, volCoord.y)].r;
                float l = _Left[volCoord.zy].r;
                float r = _Right[uint2(volSize-1-volCoord.z, volCoord.y)].r;
                float d = _Down[volCoord.xz].r;
                float u = _Up[uint2(volCoord.x, volSize-1-volCoord.z)].r;

                // Check if anything is in the tolerated depth
                float3 realPos = volCoord / float(volSize);
                if (b > (realPos.z-0.01) && f > (0.99-realPos.z) &&
                    l > (realPos.x-0.01) && r > (0.99-realPos.x) &&
                    d > 0 && u > 0) // doing same on y-axis looks kind of bad
                    return float4(realPos, 1);
                else
                    return 0;
            }
            ENDCG
        }
    }
}
