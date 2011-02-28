package iso.display
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Material
	{
		private var texture:Texture;
		private var textureData:TextureData;
		private var textureClone:BitmapData;
		private var isNeedUpload:Boolean;
		
		private static var lastUploadedTexture:Texture;
		private static var lastUploadedTextureId:String;
		
		public function Material(textureData:TextureData)
		{
			setupTextureData(textureData);
		}
		
		public function dispose():void
		{
			textureData = null;
			textureClone = null;
			texture = null;
		}
		
		public function get u():Number
		{
			return textureData.u;
		}
		public function get v():Number
		{
			return textureData.v;
		}
		
		public function get textureId():String
		{
			return textureData.id;
		}
		
		public function getBitmapData():BitmapData
		{
			return textureClone?textureClone:textureData.bitmap;
		}
		
		private var _alpha:Number = 1;
		public function setAlpha(alpha:Number):void
		{
			_alpha = alpha;
			isNeedUpload = true;
			var tf:ColorTransform = new ColorTransform(1,1,1,alpha);
			textureClone = textureData.bitmap.clone();
			textureClone.colorTransform(new Rectangle(0, 0, textureClone.width, textureClone.height), tf);
		}
		
		private var _filter:BitmapFilter;
		public function get filter():BitmapFilter
		{
			return _filter;
		}
		public function set filter(v:BitmapFilter):void
		{
			_filter = v;
			/*if(textureData)
			{
				if(_filter)
				{
					generatedFilterRect = textureData.generateFilterRect(textureBounds, _filter);
					filterData = new BitmapData(generatedFilterRect.width, generatedFilterRect.height);
					filterData.copyPixels(textureData, textureBounds, new Point(-generatedFilterRect.x, -generatedFilterRect.y));
					filterData.applyFilter(textureData, textureBounds, new Point(), _filter);
				}
				else
				{
					generatedFilterRect = null;
				}
			}*/
		}
		
		public function bindTextureAt(dest:DisplayContext3D, sampler:int):Boolean
		{
			if(isNeedUpload)uploadTexture(dest);
			
			if (texture)
			{
				dest.context3D.setTextureAt(sampler, texture);
				return true;
			}
			else return false;
		}
		
		private function uploadTexture(dest:DisplayContext3D):void
		{
			if(getCachedTexture())return;
			
			var bmd:BitmapData = getBitmapData();
			if(bmd)
			{
				texture=dest.context3D.createTexture(bmd.width, bmd.height, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(bmd);
				cacheTexture();
			}
			else
			{
				texture=null;
			}
			isNeedUpload=false;
		}
		
		private function cacheTexture():void
		{
			lastUploadedTexture = texture;
			lastUploadedTextureId = textureData.id;
		}
		
		private function getCachedTexture():Boolean
		{
			if(lastUploadedTexture && lastUploadedTextureId == textureData.id)
			{
				texture = lastUploadedTexture;
				isNeedUpload=false;
				return true;
			}
			else return false;
		}
		
		public function setupTextureData(textureData:TextureData):void
		{
			this.dispose();
			this.textureData=textureData;
			isNeedUpload=true;
			if(_alpha != 1)
			{
				setAlpha(_alpha);
			}
		}
		
	}
}