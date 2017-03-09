//unity 内部的渲染队列： Background = 1000， Geometry = 2000, AlphaTest = 2450 
//Transparent = 3000, Overlay = 4000 所以知道为什么上面的 -1000 和 -999 的区别了吧 （越大的值越后渲染）

//渲染队列的使用，可以发现不敢怪物深度测试是否通过，最总都会被遮挡
Shader "Custom/06Cube" {
	Properties {
		//_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainColor ("Color",Color) = (1,1,1,1)
	}
	SubShader {
		//对应不透明物体,先渲染离摄像机近的，所以cube比怪物先渲染。
		Tags {"Queue"="Geometry-1"}
		//由于渲染队列小于Geometry(2000) 所以先渲染cube，测试通过，并写入深度值。
		//后渲染怪物，怪物深度值大于Cube,小于场景（场景默认无穷大）,所以和Cube重合的部分测试通过，会被显示出来
		//而其他部分和场景比较，测试不通过，所以片段被丢弃。
		
		//Tags {"Queue"="Transparent-1001"}  
		pass{
			ZWrite On
			ZTest LEqual
			Color[_MainColor]
		}
	} 
	FallBack "Diffuse"
}
