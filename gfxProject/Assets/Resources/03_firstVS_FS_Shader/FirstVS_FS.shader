//一个最简单的Vertex Shader 和 PixelShader

Shader "Custom/FirstVS_FS" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}  //定义一个2d贴图,初始颜色为白色 材质参数为空
		_MainColor("Main Color",Color) = (1,1,1,1) //定义一个颜色 默认给白色
	}
	SubShader {
		Pass {
		
		CGPROGRAM
		#pragma vertex Vert
		#pragma fragment Frag 

		#include "UnityCG.cginc"
		float4 _MainColor;
		sampler2D _MainTex;
	
		float4 _MainTex_ST;  //声明对应采样信息包括tilling 和 offset   
							//_MainTex_ST 命名必须和 _MainTex ("Base (RGB)", 2D) = "white" {} 一直，不然无法获取到til和offset
								//#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
		//定义顶点结构体
		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0; 
		};
		
		//vertex Shader
		v2f Vert( appdata_base  v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);  //使用MVP矩阵变换顶点坐标
			o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);  //根据材质的tilling和Offset计算最终的顶点uv
			return o; //返回这个顶点结构给fragment shader使用
		}

		//fragment shader  返回最终的颜色片段，然后进入光栅化阶段（混合）
		float4 Frag(v2f inVert) : COLOR
		{
			float4 texCol = tex2D(_MainTex,inVert.uv);  //采样得到纹素颜色
			//float4 rgb = float4(1,0,0,1);
			texCol = texCol * _MainColor;
			return texCol;
		} 

		ENDCG
		}
		

	} 
	FallBack "Diffuse"
}
