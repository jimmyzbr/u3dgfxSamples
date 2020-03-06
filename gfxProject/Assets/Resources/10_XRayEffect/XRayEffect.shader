// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//类似火炬之光角色被障碍物遮挡之后,遮挡部分显示半透明效果的实现
//实现方法：渲染两遍，自然就要用到两个pass,一个pass渲染被遮挡后的效果，
//另外一个pass渲染正常效果。渲染被遮挡的效果，要把被遮挡物体（怪）渲染在
//阻挡物体前面，将深度测试改为ZTest Greater，再启用alpha混合（不是必须）
//给遮挡部分一个单独的颜色，关闭ZWrite,不写入深度信息。
//另外一个pass正常渲染未被遮挡的部分，开启ZWrite,ZTest 为LEqual
//


Shader "Custom/XRayEffect" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor("BaseColor",Color) = (1,1,1,1)
		_BlockColor("EffectColor",Color) = (0,1,0,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
		LOD 200
		
		//在这个Pass中渲染被遮挡的特效
		Pass
		{
			ZWrite Off   //关闭深度写入
			ZTest Greater  //深度测试 原理摄像机的测试通过
			//Blend SrcAlpha OneMinusSrcAlpha   //普通混合
			Blend SrcAlpha One //高亮融合
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainColor;
			float4 _BlockColor;

			struct V2F
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//vs
			V2F Vert(appdata_base v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			//fs
			float4 Frag(V2F inVert):SV_Target   //SV_Target:是HLSL中的一个系统语义，
												//告诉渲染器把这个函数的输出颜色存储到一个渲染目标中。
			{
				float4 texCol = _BlockColor;//= tex2D(_MainTex,inVert.uv);
				return texCol;
			}
			ENDCG
		}

		//在这个Pass中渲染正常特效
		Pass
		{
			ZWrite On  //恢复深度写入
			ZTest LEqual //深度测试还原为默认，剔除被遮挡的部分	

			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainColor;


			struct V2F
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//vs
			V2F Vert(appdata_base v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			//fs
			float4 Frag(V2F inVert):COLOR
			{
				float4 texCol = tex2D(_MainTex,inVert.uv);
				return texCol * _MainColor;
			}
			ENDCG
		}
		
	} 
	FallBack "Diffuse"
}
