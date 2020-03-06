// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//一个简单的Alpha Blending Shader

//源颜色： 当前片段着色器shader计算出来的颜色，马上要拿来进行alpha混合的颜色叫做“源”
//目标颜色：该像素点之前已经存在或者累计的颜色值成为“目标颜色”
//混合计算公式： 最终颜色 = （Shader计算出的点颜色值 * 源系数）+（点累积颜色 * 目标系数）
// 属性（往SrcFactor，DstFactor 上填的值）
// one                          1
// zero                         0
// SrcColor                     源的RGB值，例如（0.5,0.4,1）
// SrcAlpha                     源的A值, 例如0.6
// DstColor                     混合目标的RGB值例如（0.5，0.4,1）
// DstAlpha                     混合目标的A值例如0.6
// OneMinusSrcColor          (1,1,1) - SrcColor
// OneMinusSrcAlpha          1- SrcAlpha
// OneMinusDstColor          (1,1,1) - DstColor
// OneMinusDstAlpha          1- DstAlpha
// 运算法则示例：
// （注：r,g,b,a,x,y,z取值范围为[0,1]）
// （r,g,b） * a = (r*a , g*a , b*a)
// （r,g,b） * (x,y,z) = (r*x , g*y , b*z)
// （r,g,b） + (x,y,z) = (r+x , g+y , b+z)
// （r,g,b） - (x,y,z)  = (r-x , g-y , b-z)

// Blend SrcAlpha OneMinusSrcAlpha        //alpha blending
// Blend One OneMinusSrcAlpha             //premultiplied alpha blending
// Blend One One                          //additive
// Blend SrcAlpha One                     //additive blending
// Blend OneMinusDstColor One             //soft additive
// Blend DstColor    Zero                 //multiplicative
// Blend DstColor SrcColor                //2x multiplicative
// Blend Zero SrcAlpha                    //multiplicative blending for attenuation by the fragment's alpha

Shader "Custom/BlendTest" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor("Color",Color) = (1,1,1,1)
	}

	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Transparent"}  //设置渲染队列为透明物体队列

		Pass
		{
			//Blend Off					关闭混合
			//Blend SrcAlpha OneMinusSrcAlpha //把源的alpha值当作因子（浓度），把（1-源的alpha值）当作目标的浓度（正常融合）
			//Blend Zero One				  //只显示背景RGB部分 无透明通道处理，所以什么都看不到
			//Blend One Zero 					  //默认形式,只显示贴图的rgb部分，无透明通道处理,透明通道也不会显示到Color buffer中
			//Blend One One					  //只是颜色叠加 贴图和背景叠加，无Alpha透明通道处理。仅仅是颜色rgb数值的叠加更趋近于白色即（1，1，1）
			//Blend SrcAlpha Zero  //只显示贴图，虽然贴图含有alpha透明通道，但是贴图中的透明部分（即黑色部分没有颜色来显示，为0），所以乘以alpha值得到结果
								 //依然是0；而且混合的目标（即背景）的颜色乘以Zero,也是0，所以透明部分的颜色相加(0 + 0 = 0 )最终也是0，所以显示为（0，0，0）黑色
			
			Blend SrcAlpha One   //高亮融合
			ZWrite Off			//渲染透明物体，一定要关闭深度缓存的写入 并且渲染顺序由后往前渲染
			
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"

			float4 _MainColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;		//采样需要的 tilling 和 offset


			//定义顶点结构
			struct V2F
			{
				float4 pos : SV_POSITION; 
				float2	uv : TEXCOORD0;
			};

			//vs
			V2F Vert( appdata_base v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			//fs
			float4 Frag(V2F inVert) : COLOR
			{
				float4 texCol = tex2D(_MainTex,inVert.uv); //得到采样后的颜色值
				return texCol * _MainColor;
			}

			ENDCG
		}

	} 
	FallBack "Diffuse"
}
