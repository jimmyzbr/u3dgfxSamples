// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//使用多Pass和背面剔除、以及Alpha Blend创建一个双面材质

Shader "Custom/TwoSideTranparent" {
	Properties {
		//_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor("Front Color",Color) = (1,1,1,1)
		_MainColor2("Back Color",Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
		LOD 200
		
		//在这个Pass 剔除背面，渲染前面，然后进行普通混合
		Pass
		{

			Cull Back			//背面剔除 渲染前面
			ZWrite Off			//关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha		//普通混合
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"


			float4 _MainColor;		//定义颜色

			struct V2F
			{
				float4 pos : SV_POSITION;
			};
			
			//vs
			V2F Vert(appdata_base v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);		//使用mvp矩阵变换顶点坐标
				return o;
			}
			//fs
			float4 Frag(V2F inVert) : COLOR
			{
				return _MainColor;
			}
			ENDCG
		}

		//在这个Pass剔除前面部分 渲染后面
		Pass
		{
			Cull Front			//背面剔除 渲染前面
			ZWrite Off			//关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha		//普通混合
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"


			float4 _MainColor2;		//定义颜色

			struct V2F
			{
				float4 pos : SV_POSITION;
			};
			
			//vs
			V2F Vert(appdata_base v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);		//使用mvp矩阵变换顶点坐标
				return o;
			}
			//fs
			float4 Frag(V2F inVert) : COLOR
			{
				return _MainColor2;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
