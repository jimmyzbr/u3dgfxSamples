//用于进行后处理的基类，unity后处理过程同城如下：
// 1. 在摄像机上添加一个用于屏幕后处理的脚本，
// 2. 在这个脚本中实现OnRenderImage函数来获取当前屏幕的渲染纹理
// 3. 调用Graphics.Bilt函数使用特定的Shader对当前图像进行处理，再把返回的渲染纹理显示到屏幕上。
// 4. 对于一些复杂的屏幕特效，可能需要多次调用Graphics.Blit函数来对上一步的输出结果进行下一步处理。

using UnityEngine;
using System.Collections;

[ExecuteInEditMode]  //在编辑器状态下也可以执行
[RequireComponent(typeof(Camera))]

public class PostEffectBase : MonoBehaviour {

	// Use this for initialization
	void Start () {
		CheckResources();
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	protected void CheckResources()
	{
		//检查当前平台是否支持后处理
		if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
		{
			Debug.LogWarning(" does not support image effects of renderTextures");
			this.enabled = false;
			return;
		}
	}

	//根据后处理Shader创建材质
	public Material CreateMaterial(Shader shader,Material mtl)
	{
		if (shader == null) 
			return null;
			//如果传入的shader正好是我们需要的，直接返回
		if (shader.isSupported && mtl && mtl.shader == shader)
			return mtl;

		if (shader.isSupported == false)
			return null;
		else{
			//创建材质
			Material mat = new Material(shader);
			mat.hideFlags = HideFlags.DontSave;
			return mat;
		}
		
	}
}
