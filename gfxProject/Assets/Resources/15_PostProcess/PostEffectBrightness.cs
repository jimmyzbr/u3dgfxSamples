using UnityEngine;
using System.Collections;

//这个脚本需要挂载到摄像机上面，来获取当前屏幕的渲染纹理
//后处理特效，调整屏幕的亮度、饱和度、和对比度
public class PostEffectBrightness : PostEffectBase {

	//声明需要使用到的shader和材质
	public Shader m_shader;    //后处理指定的shader
	Material m_mtl = null;		//创建的材质

	//效果参数
	[Range(0.0f,3.0f)]
	public float brightness = 1.0f;  //亮度
	[Range(0.0f,3.0f)]
	public float saturation = 1.0f; //饱和度
	[Range(0.0f,3.0f)]
	public float contrast = 1.0f;	//对比度

	void Start () {
	
	}
	
	/// <summary>
	/// OnRenderImage is called after all rendering is complete to render image.
	/// </summary>
	/// <param name="src">The source RenderTexture.</param>
	/// <param name="dest">The destination RenderTexture.</param>
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		//根据shader得到材质 如果不存在就创建
		m_mtl = this.CreateMaterial(m_shader,m_mtl);
		if(m_mtl != null)
		{
			//给材质设置亮度 饱和度 对比度属性，然后通过材质传递给shader，最后在shader中进行计算
			m_mtl.SetFloat("_Brightness",brightness);
			m_mtl.SetFloat("_Saturation",saturation);
			m_mtl.SetFloat("_Contrast",contrast);

			//完成渲染纹理处理，把原始texture拷贝到目标texture上。如果dest==null 则直接拷贝到屏幕上。
			//m_mtl中的shader将会进行一些后处理操作 pass 默认为-1 ：依次调用shader内的所有pass
			Graphics.Blit(src,dest,m_mtl,-1);
		}
		else
		{
			Graphics.Blit(src,dest);		//如果材质为空 则不做任何事情，直接把原图显示到屏幕上。
		}
	}

	void Update () {
	
	}  
}
