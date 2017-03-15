//一个简单的Alpha测试Shader 测试通过才进行渲染 否则不渲染,默认是全渲染
// 语法：
// 第一种: AlphaTest Off： 不测试，全渲染
// 第二种：Alpha 比较符 目标alpha值
// 其中目标alpha值取值范围是 0至1， 也可以用参数 ，如 AlphaTest [varName]。
// 比较符:(目标alpha值下面记作x)
// Always  全渲染（任意x值）
// Never   全不渲染
// Greater  点的alpha值大于x时渲染
// GEuqal   点的alpha值大于等于x时渲染
// Less       点的alpha值小于x时渲染
// LEqual    点的alpha值小于等于x时渲染
// Equal  点的alpha值等于x时渲染

// NotEqual  点的alpha值不等于x时渲染


Shader "Custom/SimpleAlphaTest" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Range("Alpha Factor",Range(0,1)) = 0.5		//加一个参数进行调节
	}
	SubShader {
		Pass
		{
			//指定渲染类  和渲染队列
			Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

			//AlphaTest GEqual [_Range]  //大于=0.5测试通过,草的alpha大于0.5所以会被渲染，其余显示透明
            Blend SrcAlpha OneMinusSrcAlpha  //直接开启混合
			Material {
                Diffuse (1,1,1,1)
                Ambient (1,1,1,1)
            }
            Lighting On
			SetTexture [_MainTex] { combine texture }
		}
	} 
	FallBack "Diffuse"
}

