// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//在BlinnPhong光照模型中贴图的基本使用，使用纹理代替物体的漫反射颜色
//BlinnPhong光照模型高光的计算
// 在Phong的基础上引入新的向量h,h = 视角方向view 和光照方向L 相加后再归一化
// 
//  h = (viewDir + lightDir) /(| view + lightDir|)
//  高光计算：  Cspe = (ColorLight * Mtlspc) max(0,Normal * h)
//			   Cspe = pow(Cspe,Mgloss)

Shader "Custom/BlinnPhongBaseTexture" {
	Properties {
		_MainTex("MainTex",2D) = "white" {}		  //创建一个纹理属性 默认白色
		_Color("Color Tint",Color  ) = (1,1,1,1)   //贴图颜色
		_Specular("Specular",Color ) = (1,1,1,1)  //高光反射颜色
		_Gloss("_Gloss",Range(8.0,256)) = 32		//控制高光区域
	}
	SubShader {

		Pass
		{
			Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }   //声明该Pass使用的光照流水线
			
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCg.cginc"
			#include "Lighting.cginc"

			//定义输入顶点结构
			struct A2V
			{
				float4 vertex : POSITION;			//顶点位置
				float3 normal: NORMAL;				//顶点法线
				float4 texcoord: TEXCOORD0;			//声明第一组纹理坐标，unity会把第一组纹理坐标存储到这个变量中 
			};

			//定义输出顶点结构，给fs使用
			struct V2F
			{
				float4 pos : POSITION;			//裁剪空间中的顶点位置
				//fixed3 color : COLOR;			//最终计算出的光照颜色
				float3 normalWorld: NORMAL;			//世界空间中的顶点法线
				float4 posWorld : TEXCOORD1;			//世界坐标系中的顶点坐标  这类不能定义重复的语义 POSITION
				float2 uv : TEXCOORD0 ;		//存储顶点着色器计算得到的顶点坐标，用于fs中进行采样 
			};

			//声明外部传入的变量
			sampler2D  _MainTex;	//声明纹理采样器
			float4   _MainTex_ST;	//声明纹理属性 缩放和偏移
			fixed4 _Color;			//漫反射光颜色
			fixed4 _Specular;			//高光颜色
			float _Gloss;				//高光因子


			//顶点着色器
			V2F Vert(A2V v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex);				//计算顶点在裁减空间中的位置
				//把法线从本地坐标系转到世界坐标系中
				 //_World2Object:由世界坐标系变换到物体本地坐标系	
				o.normalWorld = normalize(mul(v.normal,(float3x3)unity_WorldToObject));  //或则直接使用内置变量
				//o.normalWorld = UnityObjectToWorldNormal(v.normal);
				
				//计算世界坐标系中的顶点坐标
				o.posWorld = mul(unity_ObjectToWorld,v.vertex);
				//计算纹理坐标
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			};

			//像素着色器
			fixed4 Frag(V2F inVert) : COLOR
			{
				//使用纹理的采样结果和颜色_Color的乘积作为材质的反射率
				fixed3 albedo = tex2D(_MainTex,inVert.uv).rgb * _Color.rgb;

				// 1. 计算环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;	//获取环境光的rgb颜色,使用内置变量 乘以纹理的反射率
				// 2. 计算漫反射光
				float3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz);		//计算世界坐标系下的光照方向
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(inVert.normalWorld,lightDirWorld));

				//3.计算高光颜色
				//计算入射光的反射方向,使用cg的reflect(refDir,normal)函数进行计算,其中refDir入射方向要求由光源指向交点处,
				//所以等于-lightDirWorld
				//float3 reflectDir = normalize(reflect(-lightDirWorld,inVert.normalWorld));
				//计算世界坐标系下摄像机的视角 (摄像机的坐标 - 顶点的坐标，都是在世界坐标系下)
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - inVert.posWorld.xyz);				
				//BlinnPhong光照模型高光的计算
				fixed3 halfDir = normalize(lightDirWorld + viewDir);
				//计算高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(inVert.normalWorld,halfDir)),_Gloss);
				
				//三种光照颜色相加
				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}
			ENDCG
		}

	} 
	FallBack "Diffuse"
}
