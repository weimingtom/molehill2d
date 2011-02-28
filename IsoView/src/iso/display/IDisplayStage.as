package iso.display
{
	public interface IDisplayStage extends IPrimitiveNode
	{
		function get useShapeFlagInHitTest():Boolean;
		function set useShapeFlagInHitTest(value:Boolean):void;
		
		function get enableRollOutTest():Boolean;
		function set enableRollOutTest(value:Boolean):void;
		
		function startMouseAction():void;
		
		function getObjectUnderPoint(stageX:Number, stageY:Number):Array;
	}
}