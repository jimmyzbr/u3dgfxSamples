Shader "Custom/LogoShine" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}  //原始图
		_FlowTex("Flow ",2D) = "white" {}		  //流光图

	}
	SubShader {

		Pass
		{
			Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
			ZWrite  Off 
			LOD 200	
			//开启alpha混合
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D  _FlowTex;
			float4 _FlowTex_ST;


			struct v2f
			{
				fixed4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0; 
				fixed2 uv_flow: TEXCOORD1;

			};

			v2f Vert( appdata_base  v) 
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv_flow = TRANSFORM_TEX(v.texcoord,_FlowTex);
				return  o;
			}

			fixed4 Frag(v2f v) : COLOR
			{
				fixed4 texCol = tex2D(_MainTex,v.uv);
				fixed4 col;

				float2 uv = v.uv;   //使用MainTex的uv
				uv.x *= 0.5;
				uv.x -= _Time.x * 15;
				//获取流光的颜色
				fixed flow = tex2D(_FlowTex,uv).a;   //alpha值来自灰度图 并且FlowTex的像素格式是alpha8
				col.rgb = texCol.rgb + fixed3(flow,flow,flow);

				col.a = texCol.a;
				return  col;
			}

			ENDCG
		}
		
	} 
	FallBack "Diffuse"
}
