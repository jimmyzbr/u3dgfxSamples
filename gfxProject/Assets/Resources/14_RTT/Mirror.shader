// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//使用RenderToTexture实现镜子的效果
//1.为了得到从镜子出发观察到的场景图形，需要再创建一个摄像机，调整它的朝向位置使它拍到的图形
//是我们希望镜子中应该呈现的图形，再创建一个RenderTexture,把它赋值给刚刚创建的摄像机的TargetTexture
//这样摄像机不需要再渲染到屏幕缓冲区上，直接渲染到RenderTexture上。

Shader "Custom/Mirror" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}   //RenderTexture
	}
	SubShader {
		
		Pass
		{
			Tags { "RenderType"="Opaque" }
			LOD 200
			
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"

			sampler2D  _MainTex;
			float4 	_MainTex_ST;
			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0 ; 
			};

			struct  v2f
			{
				float4 pos: SV_POSITION;
				float2 uv : TEXCOORD0; 
			};

			v2f Vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				//翻转纹理的u坐标 因为镜子里图形是左右相反的
				o.uv.x = 1.0 - o.uv.x;
				return  o;
			}

			float4 Frag(v2f i) : COLOR
			{
				float4 col = tex2D(_MainTex,i.uv);
				return col;
			}
			ENDCG
		}

	} 
	FallBack "Diffuse"
}
