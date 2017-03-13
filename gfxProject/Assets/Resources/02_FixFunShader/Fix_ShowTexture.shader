
//固定管线Shader 显示图片
Shader "Custom/Fix_ShowTexture" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainTex2 ("Base (RGB)", 2D) = "white" {}
		_MainColor("Color",Color) = (1,1,1)		//定义一个颜色
	}
	SubShader {
		pass{

			Material{
				Diffuse [_MainColor]
			}

			Lighting On  //开启光照

			//使用SetTexture命令设置纹理，必须放在Pass最后
			SetTexture[_MainTex]
			{
				//这个TextureBlock中定义如何设置这个纹理 主要命令有combine 、constantColor 、matrix
				//combine texture  //只写这个颜色不生效，只是简单应用这个纹理
				//颜色相乘，往往变得更暗
				combine texture * Primary //Primary颜色来自光照计算或者是顶点颜色
			}

			//第二个设置纹理命令
			SetTexture[_MainTex2]
			{
				combine texture * Previous //乘以上一个SetTexture操作得出的颜色
			}
		}
	} 
	FallBack "Diffuse"
}
