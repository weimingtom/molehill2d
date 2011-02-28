package iso.display
{
	import flash.filters.BitmapFilter;

	public interface IDisplayPrimitive
	{
		function get alpha():Number;
		function set alpha(v:Number):void;
		
		function get filter():BitmapFilter;
		function set filter(v:BitmapFilter):void;
		
		function get height():Number;
		function set height(v:Number):void;
		
		function get width():Number;
		function set width(v:Number):void;
		
		function get scaleX():Number;
		function set scaleX(v:Number):void;
		
		function get scaleY():Number;
		function set scaleY(v:Number):void;
		
		function set scale(v:Number):void;
	}
}