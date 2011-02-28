package iso.display
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DProgramType;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import iso.events.Mouse2DEvent;

	[Event(name="onMouseOver", type="iso.events.Mouse2DEvent")]
	[Event(name="onMouseOut", type="iso.events.Mouse2DEvent")]
	
	[Event(name="onRollOut", type="iso.events.Mouse2DEvent")]
	
	[Event(name="onMouseDown", type="iso.events.Mouse2DEvent")]
	[Event(name="onMouseUp", type="iso.events.Mouse2DEvent")]
	
	[Event(name="onMouseClick", type="iso.events.Mouse2DEvent")]
	
	public class TexturedQuad extends PrimitiveMesh
	{
		public var owner:Object;
		
		protected var screenWidth:Number;
		protected var screenHeight:Number;
		protected var mvp:Matrix3D;
		
		private var _isDragging:Boolean;
		
		private var dragOffsetX:Number = 0;
		private var dragOffsetY:Number = 0;
		
		public function TexturedQuad(textureData:TextureData, width:Number = -1, height:Number = -1)
		{
			super(new Material(textureData));
			
			var w:Number = width<0?textureData.width:width;
			var h:Number = height<0?textureData.height:height;
			this.width = w;
			this.height = h;
			rawWidth = w;
			rawHeight = h;
			mouseEnabled = true;
		}
		
		override public function dispose():void
		{
			owner = null;
			super.dispose();
		}
		
		private var _mouseEnabled:Boolean;
		public function get mouseEnabled():Boolean
		{
			return _mouseEnabled;
		}
		public function set mouseEnabled(value:Boolean):void
		{
			_mouseEnabled = value;
		}
		
		protected function buildPrimitive(stageWidth:Number, stageHeight:Number):void
		{
			_geometryDirty = false;
			
			var fw:Number = 2/stageWidth;
			var fh:Number = 2/stageHeight;
			
			var w:Number = fw*_width;
			var h:Number = fh*_height;
			
			screenWidth = _rawWidth * fw * _scaleX;
			screenHeight =_rawHeight * fh * _scaleY;
			
			vertexStream=new Vector.<Number>(12, true);
			vertexStream[0] = 0; vertexStream[1] = 0; vertexStream[2] = 0;
			vertexStream[3] = 0; vertexStream[4] = h; vertexStream[5] = 0;
			vertexStream[6] = w; vertexStream[7] = h; vertexStream[8] = 0;
			vertexStream[9] = w; vertexStream[10] = 0; vertexStream[11] = 0;
			
			computeBoundingBox();
			isNeedUpload = true;
		}
		
		override public function prerender(dest:DisplayContext3D):void
		{
			if (_visible)
			{
				if(_geometryDirty)
				{
					var vp:Rectangle = dest.viewPort;
					buildPrimitive(vp.width, vp.height);
				}
				
				// setup matrices
				if(!mvp  || _primitiveDirty)
				{
					mvp=getWorldMatrix().clone();
					mvp.append(dest.viewProjection);
				}
				
				// check bb 
				if (boundingbox && !isboundingBoxVisibleInClipspace(mvp, boundingbox))
					return;
				
				_globalDepth = dest.depth;
				
				dest.depth ++;
				dest.addQuadForBatch(getBatchId(), this, isNeedUpload);
				
				isNeedUpload = false;
				
				for each(var child:PrimitiveNode in _children)
				{
					child.prerender(dest);
				}
			}
		}
		
		internal function getBatchId():String
		{
			return material.textureId;
		}
		
		internal function batchRender(batchContext:BatchQuadContext, dt:int, isVertexDirty:Boolean):void
		{
			//dest.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, _mvp, true ); // modelviewprojection			
			if (isVertexDirty)
			{
				var u:Number = material.u;
				var v:Number = material.v;
				var d:Number = _globalDepth/100000;
				
				var vout:Vector.<Number> = new Vector.<Number>(vertexStream.length, true);
				mvp.transformVectors(vertexStream, vout);
				
				//x, y, z ,  u ,v
				var p:uint = batchContext.position;
				var stream:Vector.<Number> = batchContext.vertexStream;
				stream[p  ] = vout[0]; stream[p+1] = vout[1]; stream[p+2] = d; stream[p+3] = 0;stream[p+4] = 0;
				stream[p+5] = vout[3]; stream[p+6] = vout[4]; stream[p+7] = d; stream[p+8] = 0;stream[p+9] = v;
				stream[p+10] = vout[6]; stream[p+11] = vout[7]; stream[p+12] = d; stream[p+13] = u;stream[p+14] = v;
				stream[p+15] = vout[9]; stream[p+16] = vout[10]; stream[p+17] = d; stream[p+18] = u;stream[p+19] = 0;
				batchContext.position+=20;
			}
		}
		
		public function bindTexture(dest:DisplayContext3D):void
		{
			material.bindTextureAt(dest, 0); //we only use one texture.
		}
		
		override public function getBoundsInWindowCoordinate(targetCoordinateSpace:PrimitiveNode = null):Rectangle
		{
			var pos:Vector3D = new Vector3D();
			pos = localToGlobalInWindowCoordinate(pos);
			if(targetCoordinateSpace)
			{
				pos = targetCoordinateSpace.globalToLocalInWindowCoordinate(pos);
			}
			var rect:Rectangle = new Rectangle(pos.x, pos.y, screenWidth, screenHeight);
			return rect;
		}
		
		public function onMouseOver():void
		{
			if(_mouseEnabled)
			{
				dispatchEvent(new Mouse2DEvent(Mouse2DEvent.ON_MOUSE_OVER));
			}
		}
		public function onMouseOut():void
		{
			if(_mouseEnabled)
			{
				dispatchEvent(new Mouse2DEvent(Mouse2DEvent.ON_MOUSE_OUT));
			}
		}
		
		/*public function onRollOver(sprite:Sprite2D):void
		{
			if(_mouseEnabled)
			{
				dispatchEvent(new Mouse2DEvent(Mouse2DEvent.ON_ROLL_OVER));
			}
		}*/
		public function onRollOut():void
		{
			if(_mouseEnabled)
			{
				dispatchEvent(new Mouse2DEvent(Mouse2DEvent.ON_ROLL_OUT));
			}
		}
		
		public function onMouseDown():void
		{
			if(_mouseEnabled)
			{
				dispatchEvent(new Mouse2DEvent(Mouse2DEvent.ON_MOUSE_DOWN));
			}
		}
		public function onMouseUp():void
		{
			if(_mouseEnabled)
			{
				dispatchEvent(new Mouse2DEvent(Mouse2DEvent.ON_MOUSE_UP));
			}
		}
		
		public function onMouseClick():void
		{
			if(_mouseEnabled)
			{
				dispatchEvent(new Mouse2DEvent(Mouse2DEvent.ON_MOUSE_CLICK));
			}
		}
		
		public function startDrag(dragObjStageX:Number, dragObjStageY:Number, bounds:Rectangle = null):void
		{
			if(stage && !_isDragging)
			{
				_isDragging = true;
				dragOffsetX = dragObjStageX-x;
				dragOffsetY = dragObjStageY-y;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMove, false, 0, true);
			}
		}
		
		private function onStageMove(e:MouseEvent):void
		{
			this.position = new Vector3D(e.localX-dragOffsetX, e.localY-dragOffsetY);
		}
		
		public function stopDrag():void
		{
			if(_isDragging)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMove);
				_isDragging = false;
			}
		}
		
	}
}