// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//这是一个基于逐像素的漫反射光照模型中漫反射光的计算
//光照模型中漫反射部分计算公式：
// Cdiff = (CLight * Mdiffuse) * max(0,VertexNormal * LightDir)
// Mdiffuse : 材质的漫反射颜色
//
// 这个需要把光照颜色的计算放到像素着色器中计算，顶点位置和法线的计算放到顶点中进行

Shader "Custom/DiffusePixelLighting" {
	Properties {
		_Diffuse("Mtl Diffuse",Color) = (1,1,1,1)    //定义材质的漫反射颜色
	}
	SubShader {
		//指明光照模式是前向渲染,为了获得Unity的内置光照变量
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
		LOD 200
		Pass
		{
			CGPROGRAM
			//声明顶点和片段着色器函数
			#pragma vertex Vert	
			#pragma fragment Frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"  
            //#include "AutoLight.cginc" 

			fixed4 _Diffuse;    //材质漫反射颜色
			//定义顶点着色器的输入和输出结构体
			struct A2V			//app 2 Vertex
			{
				float4 vertex : POSITION;		//顶点坐标
				float3 normal : NORMAL;			//顶点法线
			};

			//输出结构体，给片段着色器使用
			struct V2F
			{
				float4 pos : POSITION;		//顶点位置
				//fixed3 color : COLOR;		//最终计算的顶点颜色
				float3 normal : NORMAL;
			};

			//在顶点着色器中计算光照
			V2F Vert(A2V v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);  //计算顶点位置（将顶点由模型空间变换到到裁减空间中）

				//把法线由模型空间变换到世界坐标系中 _World2Object是模型空间到世界空间的逆矩阵（世界到模型）
				//法线变换的矩阵求法： 使用顶点变换矩阵的逆矩阵的转置矩阵。
				o.normal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));//这里变换了一下方向，节省了求转置矩阵
				return o;
			}


			//片段着色器，把顶点着色器中计算得出的光照颜色输出就行
			fixed4 Frag(V2F vertex) : COLOR
			{
				fixed4 col;
				//通过内置变量得到环境光部分
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;	
				//获取世界坐标下的光源方向
				fixed3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz);  //使用内置变量 _LightColor0提供光源的颜色和强度信息

				//计算漫反射部分(max(0,dot(normalWorld,lightDirWorld)表示散射因子 需要控制在0到1之间)
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(vertex.normal,lightDirWorld));

				col.rgb  = ambient + diffuse;		//最终把环境光和漫反射光相加最后输出的光照颜色
				col.a = 1.0;
				return col;
			}

			ENDCG
		}

	} 
	FallBack "Diffuse"
}
