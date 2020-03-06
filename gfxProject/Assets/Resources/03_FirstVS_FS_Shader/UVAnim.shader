// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//一个最简单的Vertex Shader 和 PixelShader
//添加uv动画 其中贴图寻找模式必须是Repeat
Shader "Custom/UVAnim" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}  //定义一个2d贴图,初始颜色为白色 材质参数为空
		_MainColor("Main Color",Color) = (1,1,1,1) //定义一个颜色 默认给白色
	}
	SubShader {
		Pass {
		
		CGPROGRAM
		#pragma vertex Vert		//声明顶点着色器
		#pragma fragment Frag 	//声明片段着色器

		#include "UnityCG.cginc"
		
		float4 _MainColor;		//自定义的颜色
		sampler2D _MainTex;		//声明贴图采样器
	
		float4 _MainTex_ST;  //声明对应采样信息包括tilling 和 offset   
							//_MainTex_ST 命名必须和 _MainTex ("Base (RGB)", 2D) = "white" {} 一直，不然无法获取到til和offset
								//#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
		//定义顶点结构体
		struct v2f
		{
			float4 pos:SV_POSITION;		//顶点位置
			float2 uv:TEXCOORD0; 		//一级纹理坐标
		};

		/*
		struct appdata_base {
    	float4 vertex : POSITION;
   		float3 normal : NORMAL;
    	float4 texcoord : TEXCOORD0;
		};
		裁剪空间的范围是[-1,1],也就是在经过MVP矩阵后，o.pos.x/ o.pos.w 以及o.pos.y/ o.pos.w 的范围都是[-1,1] 故可以将裁剪空间坐标转换为 相对屏幕位置的uv坐标,如下
		o.uv = float2(( o.pos.x/o.pos.w+1)*0.5,(o.pos.y/o.pos.w+1)*0.5);

		*/
		
		//vertex Shader
		v2f Vert( appdata_base  v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);  //使用MVP矩阵变换顶点坐标
			o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);  //根据材质的tilling和Offset计算最终的顶点uv
			
			//_Time	float4	t 是自该场景加载开始所经过的时间，4个分量分别是 (t/20, t, t*2, t*3)
			//fixed x= Speed * _Time;  等价于 fixed x= Speed * _Time.x;
			
			float _u = o.uv.x + _Time.x * 10;  //U横向移动 放在vs中效率比fs中高
			float _v = o.uv.y + _Time.x * 5;
			o.uv = float2(_u,_v);
			return o; //返回这个顶点结构给fragment shader使用
		}

		//fragment shader  返回最终的颜色片段，然后进入光栅化阶段（混合）
		float4 Frag(v2f inVert) : COLOR
		{
			float4 texCol = tex2D(_MainTex,inVert.uv);  //采样得到纹素颜色
			texCol = texCol * _MainColor; //乘上附加颜色
			return texCol;
		} 

		ENDCG
		}
		

	} 
	FallBack "Diffuse"
}
