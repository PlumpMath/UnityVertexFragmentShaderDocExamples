﻿Shader "MyShader/05-AddingMoreTextures"
{
	Properties
	{
		// three textures we'll use in the material
		_MainTex("Base Texture", 2D) = "white" { }
		_OcclusionMap("Occlusion", 2D) = "white" { }
		_BumpMap("Normal Map", 2D) = "bump" { }
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			// exactly the same as in previous shader
			struct v2f
			{
				float3 worldPos : TEXCOORD0;
				half3 tspace0 : TEXCOORD1;
				half3 tspace1 : TEXCOORD2;
				half3 tspace2 : TEXCOORD3;
				float2 uv : TEXCOORD4;
				float4 pos : SV_POSITION;
			};

			v2f vert( float4 v : POSITION, float3 n : NORMAL, float4 t : TANGENT, float2 uv : TEXCOORD0 )
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v);
				o.worldPos = mul(_Object2World, v).xyz;
				half3 wNormal = UnityObjectToWorldNormal(n);
				half3 wTangent = UnityObjectToWorldDir(t.xyz);
				half tangentSign = t.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
				o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
				o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
				o.uv = uv;
				return o;
			}

			// textures from shader properties
			sampler2D _MainTex;
			sampler2D _OcclusionMap;
			sampler2D _BumpMap;

			fixed4 frag(v2f i) : SV_Target
			{
				// same as from previous shader
				half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tnormal);
				worldNormal.y = dot(i.tspace1, tnormal);
				worldNormal.z = dot(i.tspace2, tnormal);
				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 worldRefl = reflect(-worldViewDir, worldNormal);
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
				half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
				fixed4 c = 0;
				c.rgb = skyColor;

				// modulate sky color with the base texture, and the occlusion map
				fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
				fixed occlusion = tex2D(_OcclusionMap, i.uv).r;
				c.rgb *= baseColor;
				c.rgb *= occlusion;

				return c;
			}
			ENDCG
		}
	}
}
