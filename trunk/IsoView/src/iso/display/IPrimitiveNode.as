package iso.display
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public interface IPrimitiveNode
	{
		function get numChildren():uint;
		
		function get visible():Boolean;
		function set visible(v:Boolean):void;
		
		function get x():Number;
		function set x(v:Number):void;
		
		function get y():Number;
		function set y(v:Number):void;
		
		function get position():Vector3D;
		function set position(v:Vector3D):void;
		
		function getBoundsInWindowCoordinate(targetCoordinateSpace:PrimitiveNode = null):Rectangle;
		
		function hitTestObject(obj:PrimitiveNode):Boolean;
		function hitTestPointInWindowCoordinate(x:Number, y:Number, shapeFlag:Boolean = false):Boolean;
		function hitTestPointInStageCoordinate(stageX:Number, stageY:Number, shapeFlag:Boolean = false):Boolean;
		
		function globalToLocalInStageCoordinate(point:Vector3D):Vector3D;
		function globalToLocalInWindowCoordinate(point:Vector3D):Vector3D;
		
		function localToGlobalInStageCoordinate(point:Vector3D):Vector3D;
		function localToGlobalInWindowCoordinate(point:Vector3D):Vector3D;
		
		function addChild(child:PrimitiveNode):Boolean;
		function addChildAt(child:PrimitiveNode, index:uint):Boolean;
		
		function contains(child:PrimitiveNode):Boolean;
		
		function getChildAt(index:uint):PrimitiveNode;
		function getChildByName(name:String):PrimitiveNode;
		function getChildIndex(child:PrimitiveNode):int;
		
		function removeChild(child:PrimitiveNode):Boolean;
		function removeChildAt(index:int):PrimitiveNode;
		
		function setChildIndex(child:PrimitiveNode, index:int):void;
		function swapChildren(child1:PrimitiveNode, child2:PrimitiveNode):void;
		function swapChildrenAt(index1:int, index2:int):void;
		
		function prerender(dest:DisplayContext3D):void
	}
}