﻿// http://docs.unity3d.com/Manual/SL-VertexFragmentShaderExamples.html
// Environment Reflection using World-Space Normals
Shader "MyShader/02-SkyReflection"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f {
				half3 worldRefl : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			v2f vert ( float4 vertex : POSITION, float3 normal : NORMAL )
			{
				v2f o;
				o.pos = mul ( UNITY_MATRIX_MVP, vertex );
				// compute world space position of the vertex
				float3 worldPos = mul ( _Object2World, vertex ).xyz;
				// compute world space view direction
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				// world space normal
				float3 worldNormal = UnityObjectToWorldNormal(normal);
//				float3 worldNormal = normal;
				// world space reflection vector
				o.worldRefl = reflect(-worldViewDir, worldNormal);
//				o.worldRefl = worldNormal;
				return o;
			}

			fixed3 frag( v2f i ) : SV_Target
			{
				// sample the default reflection cubemap, using the reflection vector
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
				// decode cubemap data into actual color
				half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
				// output it!
				fixed3 c = 0;
				c = skyColor;
				return c;
			}
			ENDCG
		}
	}
}
