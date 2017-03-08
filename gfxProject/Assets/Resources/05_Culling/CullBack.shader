//简单背面裁减Culling Shader
//涉及到的命令：Cull Back ：反面不进行渲染
// Cull Front 正面不进行渲染
// Cull Off :关闭裁剪 正反面都渲染
//默认情况下裁减的是背面，因为背对相机所以没有必要进行着色

Shader "Custom/CullBack" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor("Color",Color) = (1,1,1,1)
	}
	SubShader {
		//下面有两个pass 一个渲染背面，一个渲染正面，这样做会增加面数,一般情况不要这么搞
		pass{  //至少要有一个pass
			Cull Front  //正面不渲染
			Material{
				Diffuse(0,1,0,1)  //背面渲染为绿色
			}
			//Color(1,0,0,1) //背面渲染为红色
			Lighting On   //使用了Material之后必须要开启光照 不然显示黑色 或者直接使用Color

			SetTexture[_MainTex]
			{
				combine texture  //背面设置贴图
			}
		}

		//渲染正面
		pass{
			Cull Back  //默认不写也行
			SetTexture[_MainTex]
			{
				combine texture  //正面设置贴图
			}
			
		}
	} 
	FallBack "Diffuse"
}
