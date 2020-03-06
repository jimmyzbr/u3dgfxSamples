// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//
// 空间变换：把一个向量从坐标空间A变换到坐标空间B, 并且已知坐标空间B的X,Y，Z轴在空间A中的表示（Xb，Yb,Zb）
// 那么从A到B的变换矩阵M = 把（Xb，Yb,Zb）按照“行”来放置构成一个变换矩阵。
//=============================================================================================================
//	在切线空间下计算法线贴图光照模型
// 在偏远着色器中通过纹理采样得到切线空间下的法线,然后与切线空间下的视角方向、光照方向等进行计算，得到最终的光照效果。
// 1.求模型空间到切线空间的变换矩阵。（ 先求切线空间到模型空间的变换矩阵，再求它的逆矩阵 ：在VS中按照切线的X、Y、Z轴的顺序按列排列即可。）
//  所以求模型空间到切线空间的变换矩阵： 把切线（X轴）负切线（Y轴）法线（Z轴）的顺序按行排列就行。
// 2.在VS中把视角方向和光照方向从模型空间变换到切线空间
//

Shader "Custom/NormalMapTangentSpace" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}	//diffuse贴图
		_Color("Color Tint",Color) = (1,1,1,1)      //贴图颜色
		_BumpMap("Normal Map",2D) = "bump"{}   //法线纹理 默认是用unity的内置法线纹理
		_BumpScale("Bump Scale",Range(0.1,5)) = 1.0		//控制凹凸程度
		_Specular("Specular",Color) = (1,1,1,1) //镜面高光
		_Gloss("Gloss",Range(0,256)) = 32		 //镜面光照强度

	}
	SubShader {

		Pass 
		{
			Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
			LOD 200
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			//声明变量
			sampler2D _MainTex;
			fixed4 _Color;
			sampler2D _BumpMap;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			//diffuse texture 和 normal texture的纹理属性
			float4 _MainTex_ST;
			float4 _BumpMap_ST;

			//切线空间是由顶点法线和顶点的切线构成的坐标空间
			//顶点输入结构 
			struct A2V
			{
				float4 vertex : POSITION;		//顶点位置（本地空间）
				float3 normal : NORMAL;			//法线方向（本地空间）
				float4 tangent : TANGENT;		//顶点的切线(我们需要使用切线的tagent.w分量来决定副切线的方向性)
				float4 texcoord: TEXCOORD0;		//第一组纹理的纹理坐标
			};
		
			//顶点输出结构，供fs使用
			struct V2F
			{
				float4 pos : POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;  //需要在切线空间下计算光源方向和视角方向
				float3 viewDir: TEXCOORD2;
			};

			//vs
			V2F Vert(A2V v)
			{
				V2F o;
				o.pos = UnityObjectToClipPos(v.vertex); //顶点在裁减空间的位置
				
				//分别计算颜色贴图和法线贴图的uv坐标 一般来说它们使用的是同一组坐标，计算一个就可以了。
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex); //diffuse贴图的纹理坐标
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap); //法线纹理的纹理坐标
				//计算副切线:通过切线和法线的叉乘来计算
				float3 binNormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;  //垂直于切线和法线构成平面有两个方向，w决定是哪一个方向
				//计算由模型空间到切线空间的变换矩阵
				float3x3 rotation = float3x3(v.tangent.xyz,binNormal,v.normal);  //等价于 TANGENT_SPACE_ROTATION
				
				//分别把光源方向和视角方向 从模型空间变换到切线空间，先得由世界空间变换到模型空间
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz; //点到光源的方向
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;	//点到摄像机的观察方向

				return o;
			}

			//fs 采样得到切线空间的法线方向
			fixed4 Frag(V2F v) : COLOR
			{
				fixed3 lightDirTangent = normalize(v.lightDir);		//切线空间的光源方向
				fixed3 viewDirTangent = normalize(v.viewDir);   //切线空间的视角方向
				float3 normalTangent;  //切线空间中的法线
				//采样得到切线空间的法线
				float4 normalPacked = tex2D(_BumpMap,v.uv.zw);  //像素值，需要转换为法线向量

				//normalTangent = UnpackNormal(normalPacked); // 如果在Unity中标明纹理类型为Normal Map
				//normalTangent.xy = normalTangent.xy * _BumpScale;
				normalTangent.xy = (normalPacked.xy * 2 -1) * _BumpScale;
				normalTangent.z = sqrt(1.0 - max(0,dot(normalTangent.xy,normalTangent.xy)));  //由于我们使用的是切线空间的法线向量，所以要保证法线方向为正??

				//使用颜色纹理和颜色相乘得到材质的返照率
				fixed3 albedo = tex2D(_MainTex,v.uv.xy).rgb * _Color.rgb;
				//计算环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				//计算漫反射光
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(normalTangent,lightDirTangent));

				//计算高光 BlinnPhong光照模型高光的计算
				fixed3 halfDir = normalize(lightDirTangent + viewDirTangent);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(normalTangent,halfDir)),_Gloss);

				//三种光颜色相加
				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}

	} 
	FallBack "Diffuse"
}
