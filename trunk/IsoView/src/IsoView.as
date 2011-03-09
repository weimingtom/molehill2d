package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	import iso.display.DisplayContext3D;
	import iso.display.TextureClipData;
	import iso.display.TextureData;
	import iso.display.TexturedMovie;
	import iso.display.TexturedQuad;
	import iso.events.Mouse2DEvent;
	
	[SWF(width="1024", height="1024", frameRate="30")]
	public class IsoView extends Sprite
	{
		private var tick:Timer;
		private var scene:DisplayContext3D;
		
		private var royalcottage12:TexturedQuad;
		private var schools:TextureClipData;
		
		public function IsoView()
		{
			var s:Vector.<TextureData> = new Vector.<TextureData>();
			s.push(school1, school2, school3, school4, school5, school6, school7, school8);
			schools = new TextureClipData(s);
			
			stage.stage3Ds[0].viewPort=new Rectangle(0, 0, 1024, 1024);
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreation);
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
		}
		
		public function onContextCreation(event:Event):void
		{
			scene=new DisplayContext3D(stage, stage.stage3Ds[0]);
			
			for(var i:int = 0; i < 200; i ++)
			{
				var mc:TexturedMovie = new TexturedMovie(schools, 30);
				mc.play();
				mc.position = new Vector3D(Math.random()*1000 - 500, Math.random()*1000-500);
				scene.addChild(mc);
			}
			
			var qd:TexturedQuad = new TexturedQuad(defaultTextureData);
			qd.position = new Vector3D(-512);
			scene.addChild(qd);
			
			royalcottage12 = new TexturedQuad(defaultTextureData, defaultTextureData.width, defaultTextureData.height);
			royalcottage12.addEventListener(Mouse2DEvent.ON_MOUSE_DOWN, onMouseDown);
			royalcottage12.addEventListener(Mouse2DEvent.ON_MOUSE_UP, onMouseUp);
			royalcottage12.addEventListener(Mouse2DEvent.ON_MOUSE_OUT, onMouseUp);
			royalcottage12.x = 32;
			royalcottage12.y = 144;
			scene.addChild(royalcottage12);
			
			addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		private function onRender(e:Event):void
		{
			scene.render(33);
		}
		
		private function onMouseDown(e:Mouse2DEvent):void
		{
			royalcottage12.startDrag(mouseX, mouseY);
		}
		private function onMouseUp(e:Mouse2DEvent):void
		{
			royalcottage12.stopDrag();
		}
		
		[Embed( source = "royalcottage.png" )]
		protected const royalcottage_:Class;
		private const defaultTextureData:TextureData = new TextureData((new royalcottage_() as Bitmap).bitmapData);
		
		[Embed( source = "school1.png" )]
		protected const school_1:Class;
		private const school1:TextureData = new TextureData((new school_1() as Bitmap).bitmapData);
		
		[Embed( source = "school2.png" )]
		protected const school_2:Class;
		private const school2:TextureData = new TextureData((new school_2() as Bitmap).bitmapData);
		
		[Embed( source = "school3.png" )]
		protected const school_3:Class;
		private const school3:TextureData = new TextureData((new school_3() as Bitmap).bitmapData);
		
		[Embed( source = "school4.png" )]
		protected const school_4:Class;
		private const school4:TextureData = new TextureData((new school_4() as Bitmap).bitmapData);
		
		[Embed( source = "school5.png" )]
		protected const school_5:Class;
		private const school5:TextureData = new TextureData((new school_5() as Bitmap).bitmapData);
		
		[Embed( source = "school6.png" )]
		protected const school_6:Class;
		private const school6:TextureData = new TextureData((new school_6() as Bitmap).bitmapData);
		
		[Embed( source = "school7.png" )]
		protected const school_7:Class;
		private const school7:TextureData = new TextureData((new school_7() as Bitmap).bitmapData);
		
		[Embed( source = "school8.png" )]
		protected const school_8:Class;
		private const school8:TextureData = new TextureData((new school_8() as Bitmap).bitmapData);
		
	}
}