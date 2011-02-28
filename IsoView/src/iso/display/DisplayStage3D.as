package iso.display
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public final class DisplayStage3D extends PrimitiveNode implements IDisplayStage
	{
		private var prevMouseOverList:Array;
		
		public function DisplayStage3D(stage:Stage, context:DisplayContext3D)
		{
			this.stage = stage;
			this.context = context;
		}
		
		override public function dispose():void
		{
			stage = null;
			prevMouseOverList = null;
			super.dispose();
		}
		
		private var _useShapeFlagInHitTest:Boolean;
		public function get useShapeFlagInHitTest():Boolean
		{
			return _useShapeFlagInHitTest;
		}
		public function set useShapeFlagInHitTest(value:Boolean):void
		{
			_useShapeFlagInHitTest = value;
		}

		private var _enableRollOutTest:Boolean = true;
		public function get enableRollOutTest():Boolean
		{
			return _enableRollOutTest;
		}
		public function set enableRollOutTest(value:Boolean):void
		{
			_enableRollOutTest = value;
		}

		
		public function startMouseAction():void
		{
			if(stage)
			{
				stage.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			}
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			var result:Array = getObjectUnderPoint(e.localX, e.localY);
			var sprite:TexturedQuad = getTopLevel(result);
			if(sprite)sprite.onMouseClick();
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			var result:Array = getObjectUnderPoint(e.localX, e.localY);
			var sprite:TexturedQuad = getTopLevel(result);
			if(sprite)sprite.onMouseDown();
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			var result:Array = getObjectUnderPoint(e.localX, e.localY);
			var sprite:TexturedQuad = getTopLevel(result);
			if(sprite)sprite.onMouseUp();
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			var result:Array = getObjectUnderPoint(e.localX, e.localY);
			
			var topSprite:TexturedQuad = getTopLevel(result);
			if(topSprite && (!prevMouseOverList || prevMouseOverList.indexOf(topSprite) == -1))
			{
				topSprite.onMouseOver();
			}
			
			if(prevMouseOverList)
			{
				for each(var item:TexturedQuad in prevMouseOverList)
				{
					if(result.indexOf(item) == -1)
					{
						item.onMouseOut();
						
						if(_enableRollOutTest)
						{
							var isOneOfSelectedIsItemChild:Boolean = false;
							for each(var sel:PrimitiveNode in result)
							{
								var p:PrimitiveNode = sel.parent;
								while(p && p!= this)
								{
									if(p == item)
									{
										isOneOfSelectedIsItemChild = true;
										break;
									}
									p = p.parent;
								}
							}
							if(!isOneOfSelectedIsItemChild)
							{
								item.onRollOut();
							}
						}
					}
				}
			}
			
			prevMouseOverList = result;
		}
		
		public function getObjectUnderPoint(stageX:Number, stageY:Number):Array
		{
			var result:Array = [];
			var i:int = 0;
			if(stage)
			{
				var rect:Rectangle = context.viewPort;
				var shapeFlag:Boolean = _useShapeFlagInHitTest;
				var windowX:Number=(stageX / rect.width) * 2.0 - 1.0;
				var windowY:Number=(stageY / rect.height) * 2.0 - 1.0;
				getObjectUnderPointInWindowCoordinate(windowX, windowY, shapeFlag, result);
			}
			return result;
		}
		
		private function getTopLevel(nodeList:Array):TexturedQuad
		{
			var result:TexturedQuad;
			for each(var node:PrimitiveNode in nodeList)
			{
				if(node is TexturedQuad)
				{
					var sp:TexturedQuad = node as TexturedQuad;
					if(sp.mouseEnabled)
					{
						if(result)
						{
							if(result._globalDepth < sp._globalDepth)result = sp;
						}
						else result = sp;
					}
				}
			}
			return result;
		}
	}
}