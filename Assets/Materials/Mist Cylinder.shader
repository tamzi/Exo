// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/Mist Cylinder" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_Intensity("Intensity", Range(0.0, 10.0)) = 1.0
		_SpeedFactor("Speed Factor", Range(-100.0, 100.0)) = 1.0
		_Yuv("Y UV fix", Range(0, 1)) = 0.95
		_FadePower("Fade Power", Range(0, 50)) = 1.0
	}

		SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

		ZWrite Off
		Blend SrcAlpha One

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Intensity;
			float _SpeedFactor;
			float _Yuv;
			float _FadePower;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float left = (1.0 - _Yuv) / 2.0;
				// prevent repeat seam on height 
				i.texcoord.y = i.texcoord.y * _Yuv + left;
				i.texcoord.x += _Time[0] * _SpeedFactor;
				fixed4 tex = tex2D(_MainTex, i.texcoord);
				fixed4 col = _Color * _Intensity;
				col.a = tex.a * pow(i.texcoord.y, _FadePower);
				return col;
			}
			ENDCG
		}
	}
}
