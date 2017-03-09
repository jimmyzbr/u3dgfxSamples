//unity 内部的渲染队列： Background = 1000， Geometry = 2000, AlphaTest = 2450 
//Transparent = 3000, Overlay = 4000 所以知道为什么上面的 -1000 和 -999 的区别了吧 （越大的值越后渲染）

//渲染队列的使用，可以发现不敢怪物深度测试是否通过，最总都会被遮挡
Shader "Custom/06Cube" {
	Properties {
		//_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor ("Color",Color) = (1,1,1,1)
	}
	SubShader {
		Tags {"Queue"="Transparent-1001"}  //由于渲染队列小于Geometry(2000) 所以先渲染cube，后渲染怪物（不管它深度测试结果怎么样）
		pass{
			Color[_MainColor]
		}
	} 
	FallBack "Diffuse"
}
