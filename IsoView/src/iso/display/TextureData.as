package iso.display
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public final class TextureData
	{
		public static const EMPTY_TEXTURE:TextureData = new TextureData();
		
		private static const ZERO:Point = new Point();
		
		public var bitmap:BitmapData;
		public var u:Number, v:Number;
		
		public var id:String;
		
		private static var _id:Number = 0;
		
		public function TextureData(src:BitmapData = null)
		{
			id = "TD_" + (_id++);
			update(src);
		}
		
		private var _width:int;
		public function get width():int
		{
			return _width;
		}
		
		private var _height:int;
		public function get height():int
		{
			return _height;
		}
		
		public function update(src:BitmapData):void
		{
			if(!src)
			{
				src = new BitmapData(128,128);
			}
			
			bitmap = buildBitmapData(src);
			_width = src.width;
			_height = src.height;
			u = _width/bitmap.width;
			v = _height/bitmap.height;
		}
		
		private static function buildBitmapData(src:BitmapData):BitmapData
		{
			var result:BitmapData;
			var natureRect:Rectangle = new Rectangle(0,0,src.width,src.height);
			var w:int = buildTextureSize(src.width);
			var h:int = buildTextureSize(src.height);
			if(w!=src.width || h != src.height)
			{
				result = new BitmapData(w,h);
				result.copyPixels(src, natureRect,ZERO);
			}
			else result = src;
			return result;
		}
		private static function buildTextureSize(src:int):int
		{
			var rebuildSize:int = 0;
			if(src < 2 || !is2Power(src))
			{
				if(src<2)rebuildSize=2;
				else if(src<4)rebuildSize=4;
				else if(src<8)rebuildSize=8;
				else if(src<16)rebuildSize=16;
				else if(src<32)rebuildSize=32;
				else if(src<64)rebuildSize=64;
				else if(src<128)rebuildSize=128;
				else if(src<256)rebuildSize=256;
				else if(src<512)rebuildSize=512;
				else if(src<1024)rebuildSize=1024;
				else
				{
					rebuildSize=1024;
					throw new Error("texture size is lager than 1024!");
				}
			}
			else rebuildSize = src;
			return rebuildSize;
		}
		
		private static function min(a:int, b:int):int
		{
			return a > b ? b : a;
		}
		
		private static function max(a:int, b:int):int
		{
			return a > b ? a : b;
		}
		
		private static function is2Power(value:int):Boolean
		{
			return value > 0 ? ((value & (~value + 1)) == value ? true : false) : false;
		}
	}
}