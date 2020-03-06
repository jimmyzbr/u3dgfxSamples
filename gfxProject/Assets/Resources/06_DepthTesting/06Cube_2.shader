// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//对比06Cube.Shader 展示RenderQueue对渲染顺序的影响
//Queue值越小越先进行渲染，值越大，越后进行渲染

Shader "Custom/06Cube_2" {
	Properties {
		//_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor("Color",Color) = (1,0,0,1)
	}

	SubShader {

		//设置渲染队列,在所有非透明物体渲染之后进行渲染
		
		Tags {"Queue"="Geometry+1"} //最后渲染啦,越靠近摄像机，深度值越小，在默认情况下，越容易测试通过
		//Tags{ "Queue" = "Geometry-2"} //最先渲染，怪物和它的重叠部分会测试通过（怪物深度大于使用这个shader的Cube）,所以怪物会显示在它前面
		pass{
		//默认开启ZWrite ZTest为小于等于通过

		CGPROGRAM
		#pragma only_renderers d3d9
		#pragma vertex Vert		//声明顶点着色器
		#pragma fragment Frag 	//声明片段着色器
		#include "UnityCG.cginc"

		//声明颜色
		float4 _MainColor;
		//定义一个顶点结构,只有一个位置信息
		struct v2f
		{
			float4 pos:SV_POSITION;

		};  //分号不能忘记

		//vs函数，返回顶点结构域体
		v2f Vert(appdata_base v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);		//使用mvp矩阵变换顶点，计算顶点坐标
			return o;
		}

		//fs函数，输出颜色
		float4 Frag(v2f i) : COLOR
		{
			//直接输出一个颜色
			//return float4(1,0,0,1)
			return _MainColor;
		}

		ENDCG
		}
	}

	//FallBack "Diffuse"
}
