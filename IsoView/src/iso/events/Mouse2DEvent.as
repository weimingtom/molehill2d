package iso.events
{
	import flash.events.Event;
	
	public class Mouse2DEvent extends Event
	{
		public static const ON_MOUSE_OVER:String = "onMouseOver";
		public static const ON_MOUSE_OUT:String = "onMouseOut";
		
		//public static const ON_ROLL_OVER:String = "onRollOver";
		public static const ON_ROLL_OUT:String = "onRollOut";
		
		public static const ON_MOUSE_DOWN:String = "onMouseDown";
		public static const ON_MOUSE_UP:String = "onMouseUp";
		
		public static const ON_MOUSE_CLICK:String = "onMouseClick";
		
		public function Mouse2DEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}