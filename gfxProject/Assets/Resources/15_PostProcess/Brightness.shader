// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//简单的后处理shader 用于调整平面 亮度 饱和度 对比度

Shader "Custom/Brightness" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}  //Graphics.Bilt(src,dest) 中的第一个参数会传递给_MainTex
		
		//这些变量其实可以不用声明，因为材质是临时创建的，这些属性直接由脚本传递给shader
		_Brightness("Brightness",Float) = 1.0	 //亮度
		_Saturation("Saturation",Float) = 1.0	 //饱和度
		_Contrast("Contrast",Float) = 1.0		//对比度
	}

	SubShader {
		Pass
		{
			ZTest Always 
			Cull Off
			ZWrite Off  //关闭深度写入，如果不关闭，会影响后面Pass透明物体的渲染
			
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float _Brightness;
			float _Saturation;
			float _Contrast;

			struct V2F
			{
				float4 pos : POSITION;
				half2 uv : TEXCOORD0;
			};

			/*
			struct appdata_img {
    		float4 vertex : POSITION;
    		half2 texcoord : TEXCOORD0;
			};
			*/

			//vs
			V2F Vert(appdata_img v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);   //顶点变换
				o.uv = v.texcoord;							//纹理坐标变换
				return o;
			}

			//在fs中进行饱和度 对比度 亮度的计算
			fixed4 Frag(V2F v) : COLOR
			{
				//采样得到纹理颜色
				float4 rtCol = tex2D(_MainTex,v.uv);

				//亮度
				float3 finalColor = rtCol.rgb * _Brightness;
				//饱和度
				fixed luminance = 0.0215 * rtCol.r + 0.7154 * rtCol.g + 0.0721 * rtCol.b;
				fixed3 luminanceCol = fixed3(luminance,luminance,luminance);
				finalColor = lerp(luminanceCol,finalColor,_Saturation);

				//对比度
				fixed3 avgColor = fixed3(0.5,0.5,0.5);
				finalColor = lerp(avgColor,finalColor,_Contrast);

				return fixed4(finalColor,rtCol.a);
			}

			ENDCG
		}

	} 
	FallBack "Diffuse"
}
