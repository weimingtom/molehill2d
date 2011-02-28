package iso.display
{
	public final class TextureClipData
	{
		public var textureData:Vector.<TextureData>;
		public var id:String;
		
		private static var _id:Number = 0;
		public function TextureClipData(textureData:Vector.<TextureData>)
		{
			id = "TC_"+ (_id++);
			this.textureData = textureData;
		}
	}
}