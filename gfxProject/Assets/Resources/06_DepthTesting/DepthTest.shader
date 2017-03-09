//深度测试，默认情况下ZWrite = On ZTest = LEqual时测试通过 越靠近相机显示优先级越高

// 1.当ZWrite为On时，ZTest通过时，该像素的深度才能成功写入深度缓存，同时因为ZTest通过了，该像素的颜色值也会写入颜色缓存。 (如果测试不通过，片段会被丢弃)
// 2.当ZWrite为On时，ZTest不通过时，该像素的深度不能成功写入深度缓存，同时因为ZTest不通过，该像素的颜色值不会写入颜色缓存。 （测试不通过，丢弃片段）
// 3.当ZWrite为Off时，ZTest通过时，该像素的深度不能成功写入深度缓存（Zwrite OFF），同时因为ZTest通过了，该像素的颜色值会写入颜色缓存。 
// 4.当ZWrite为Off时，ZTest不通过时，该像素的深度不能成功写入深度缓存，同时因为ZTest不通过，该像素的颜色值不会写入颜色缓存。（测试不通过，丢弃片段）
// 总结：zwrite只是处理深度值，ztest才是决定采用谁的颜色值，zwrite只是为ztest服务的。默认情况下unity采用的是zwrite为on，ztest为lqeual 也就是越靠近相机的显示优先级越高。

Shader "Custom/DepthTest" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		pass{
			
			Material{
				Diffuse(1,1,1,1)
			}
			Lighting On
			ZWrite On  //开启或关闭写入深度缓存
			//ZTest Always //测试总是通过，则怪物虽然被cube遮挡 但是总能显示出来	
			ZTest Greater //在片段深度值大于缓冲区的深度时通过测试(越靠近摄像机反而会被丢弃，不进行渲染)
			SetTexture[_MainTex]
			{
				combine texture
			}
		}
	} 
	FallBack "Diffuse"
}
