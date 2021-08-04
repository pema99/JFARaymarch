// This shader implements a single JFA step

Shader "Pema99/JFA/JFAShader"
{
    Properties
    {
        _MainTex ("Previous Pass Tex", 2D) = "white" {}
        [IntRange] _Pass ("Pass Number", Range(0, 7)) = 0
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
                // Get step size, half each time
                int stepSize = pow(2, log2(volSize) - 1 - _Pass);

                // Calculate [0; 1] coordinate in volume of current fragment
                uint2 texCoord = i.uv * texSize;
                float3 volCoord = TexToVol(texCoord) + 0.5;
                float3 volUV = volCoord / float(volSize);

                // Go through all 27 cells in neighborhood, find closest valid seed
                float3 closestSeed;
                float closestDist = 100000;
                for (int x = -1; x <= 1; x++)
                {
                    for (int y = -1; y <= 1; y++)
                    {
                        for (int z = -1; z <= 1; z++)
                        {
                            int3 seedCoord = volCoord + int3(x, y, z) * stepSize;
                            float3 seed = _MainTex[VolToTex(seedCoord)].xyz;
                            float dist = distance(seed, volUV);
                            if (dist < closestDist && any(seed))
                            {
                                closestSeed = seed;
                                closestDist = dist;
                            }
                        }
                    }
                }

                // Return coords of closest seed
                return closestSeed;
            }
            ENDCG
        }
    }
}
