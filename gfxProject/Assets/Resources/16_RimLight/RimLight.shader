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

//======================================================================================
//在BlinnPhong光照模型中实现RimLight 边缘光效果  http://blog.csdn.net/puppet_master/article/details/53548134
// 边缘光的判断：通过顶点法线和视角的夹角来判断该顶点是否位于物体的边缘：当夹角越小=0 时，顶点法线和视角方向垂直
// 此时对于视角来说认为顶点位于正面，当夹角等于90度，相互垂直时，说明法线对应的面和视线相互平行，对于视角来说认为该顶点处于边缘


Shader "Custom/RimLight" {
	Properties {
		_MainTex("MainTex",2D) = "white" {}		  //创建一个纹理属性 默认白色
		_Color("Color Tint",Color  ) = (1,1,1,1)   //贴图颜色
		_Specular("Specular",Color ) = (1,1,1,1)  //高光反射颜色
		_Gloss("_Gloss",Range(8.0,256)) = 32		//控制高光区域
		_RimColor("RimColor",Color) = (1,1,1,1)    //边缘光颜色
		_RimPower("RimPower",Range(0.00001,3.0)) = 1.0    //边缘光强度
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
				float3 normalWorld: NORMAL;			//世界空间中的顶点法线
				float4 posWorld : TEXCOORD1;			//世界坐标系中的顶点坐标  这类不能定义重复的语义 POSITION
				float2 uv : TEXCOORD0 ;		//存储顶点着色器计算得到的顶点坐标，用于fs中进行采样 
				float3 viewDir : TEXCOORD2 ;
				
			};

			//声明外部传入的变量
			sampler2D  _MainTex;	//声明纹理采样器
			float4   _MainTex_ST;	//声明纹理属性 缩放和偏移
			fixed4 _Color;			//漫反射光颜色
			fixed4 _Specular;			//高光颜色
			float _Gloss;				//高光因子
			fixed4 _RimColor;		//边缘光颜色
			float _RimPower;		//边缘光强度



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

				//计算世界坐标下的viewDir 放在这里逐个顶点计算要省很多(计算世界坐标系下摄像机的视角 (摄像机的坐标 - 顶点的坐标，都是在世界坐标系下))
				o.viewDir  = _WorldSpaceCameraPos.xyz - o.posWorld.xyz;
				
				return o;
			};

			//像素着色器
			fixed4 Frag(V2F inVert) : COLOR
			{
				//归一化法线方向和视角
				float3 worldNormal = normalize(inVert.normalWorld);
				float3 viewDir = normalize(inVert.viewDir);	
				//使用纹理的采样结果和颜色_Color的乘积作为材质的反射率
				fixed3 albedo = tex2D(_MainTex,inVert.uv).rgb * _Color.rgb;


				// 1. 计算环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;	//获取环境光的rgb颜色,使用内置变量 乘以纹理的反射率
				// 2. 计算漫反射光
				float3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz);		//计算世界坐标系下的光照方向
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,lightDirWorld));

				//计算边缘光的颜色
				//计算viewDir和normal的夹角，dot(view,normal)越大 夹角约趋向0，边缘光左右越弱
				float rim = 1.0 - max(0,dot(viewDir,worldNormal));
				fixed3 rimColor = _RimColor * pow(rim,1/_RimPower);
				diffuse += rimColor;   //漫反射光加上边缘光

				//3.计算高光颜色
				//计算入射光的反射方向,使用cg的reflect(refDir,normal)函数进行计算,其中refDir入射方向要求由光源指向交点处,
				//所以等于-lightDirWorld
				//float3 reflectDir = normalize(reflect(-lightDirWorld,inVert.normalWorld));
				
							
				//BlinnPhong光照模型高光的计算
				fixed3 halfDir = normalize(lightDirWorld + viewDir);
				//计算高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
				
				//三种光照颜色相加
				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}
			ENDCG
		}

	} 
	FallBack "Diffuse"
}
