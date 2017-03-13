
//固定渲染管线Shader,显示单一颜色
Shader "Custom/fixFun_showColor" {
	Properties {
		//_MainTex ("Base (RGB)", 2D) = "white" {}
		//定义一个颜色
		_Color("Main Color",Color) = (1,0.5,0.5,1)
	}
	//子shader 包含了一个通道（Pass），它开启了顶点光，并设置材质颜色 什么都不设置则默认显示黑色
	SubShader {
		pass {
			Material{
				//显示该颜色
				Diffuse [_Color]
			}	
			Lighting On  //打开光照开关，接受光照
		}
	}
}
