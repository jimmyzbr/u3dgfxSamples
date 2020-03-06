// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/LogoShine" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}  //原始图
		_FlowTex("Flow ",2D) = "white" {}		  //流光图（warpmode = repeat）

	}
	SubShader {

		Pass
		{
			Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
			ZWrite  Off   //关闭像素点深度值的写入
			LOD 200	
			//开启alpha混合
			Blend SrcAlpha OneMinusSrcAlpha  //正常模式(透明度混合) 
			
			//透明值Alpha越高，越不透明
            //最终颜色 = 源颜色 * 源透明值 + 目标颜色 * （1 - 源透明值）
            //结论：贴图alpha值越大，颜色越偏向贴图；alpha值越小，颜色越偏向混合目标
            
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;  //声明对应采样信息包括tilling 和 offset   

			sampler2D  _FlowTex;
			float4 _FlowTex_ST; //声明对应采样信息包括tilling 和 offset   


            //顶点信息结构体
			struct v2f
			{
				fixed4 pos : SV_POSITION; //MVP矩阵变换后的顶点坐标
				fixed2 uv : TEXCOORD0;  //一级纹理坐标
				fixed2 uv_flow: TEXCOORD1; //二级纹理坐标,流光图

			};

			v2f Vert( appdata_base  v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);          //根据材质的tilling和Offset计算最终的顶点uv
				o.uv_flow = TRANSFORM_TEX(v.texcoord,_FlowTex);
				return  o;
			}

           // _Time各个分量的值如下：     
           // _Time.x = time / 20
           // _Time.y = time
           // _Time.z = time * 2
           // _Time.w = time * 3
            
			fixed4 Frag(v2f v) : COLOR
			{
				fixed4 texCol = tex2D(_MainTex,v.uv);
				fixed4 col;

				float2 uv = v.uv_flow;   //使用流光图的uv
				uv.x = uv.x - _Time.y*1.5; //纹理uv坐标在x方向上进行偏移

				//获取流光的颜色
				fixed flow = tex2D(_FlowTex,uv).a;   //alpha值来自灰度图 并且FlowTex的像素格式是alpha8
				col.rgb = texCol.rgb + fixed3(flow,flow,flow); //使用颜色叠加（黑色为0，相加后不影响，高亮出相加后颜色变亮）
				//col.rgb = fixed3(flow, flow, flow); //调试查看uv
				col.a = texCol.a;
				return  col;
			}

			ENDCG
		}
		
	} 
	FallBack "Diffuse"
}
