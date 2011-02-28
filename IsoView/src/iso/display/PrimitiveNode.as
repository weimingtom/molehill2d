package iso.display
{
	import flash.display.Display3D;
	import flash.display.Stage;
	import flash.display3D.Context3DProgramType;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class PrimitiveNode extends EventDispatcher implements IPrimitiveNode
	{
		public var name:String;
		public var stage:Stage;
		
		protected var modelMatrix:Matrix3D; 
		protected var worldMatrix:Matrix3D;
		protected var worldPosition:Vector.<Number>;
		
		protected var _primitiveDirty:Boolean;
		
		public function PrimitiveNode()
		{
			modelMatrix = new Matrix3D;
			modelMatrix.identity();
			_primitiveDirty = true;
			worldPosition = new Vector.<Number>(4);
			_children = [];
			
		}
		public function dispose():void
		{
			for each(var node:PrimitiveNode in _children)
			{
				node.dispose();
			}
			_children = null;
			_isDisposed = true;
		}
		
		private var _isDisposed:Boolean;
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function get numChildren():uint
		{
			return _children.length;
		}
		
		protected var _parent:PrimitiveNode;
		public function get parent():PrimitiveNode
		{
			return _parent;
		}
		
		internal var _globalDepth:int;
		public function get globalDepth():int
		{
			return _globalDepth;
		}
		
		protected var _children:Array;
		public function getChildren():Array
		{
			return _children.concat();
		}
		
		private var _context:DisplayContext3D;
		public function get context():DisplayContext3D
		{
			return _context;
		}
		public function set context(value:DisplayContext3D):void
		{
			_context = value;
			if(_context)
			{
				if(!isNaN(_x))
				{
					x = _x;
					_x = NaN;
				}
				if(!isNaN(_y))
				{
					y = _y;
					_y = NaN;
				}
				if(_position)
				{
					position = _position;
					_position = null;
				}
			}
		}
		
		protected var _visible:Boolean = true;
		public function get visible():Boolean
		{
			return _visible;
		}
		public function set visible(v:Boolean):void
		{
			if(_visible != v)
			{
				_visible = v;
				dirtyPrimitive();
			}
		}
		
		private var _x:Number;
		public function get x():Number
		{
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				return (modelMatrix.position.x) * rect.width * 0.5;
			}
			else return 0;
		}
		public function set x(v:Number):void
		{
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				var position:Vector3D = modelMatrix.position;
				var value:Vector3D = new Vector3D(v/(rect.width*0.5), position.y, position.z);
				if(value.x != position.x)
				{
					modelMatrix.position = value;
					dirtyPrimitive();
				}
			}
			else
				_x = v;
		}
		
		private var _y:Number;
		public function get y():Number
		{
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				return (modelMatrix.position.y)* rect.height * 0.5;
			}
			else return 0;
		}
		public function set y(v:Number):void
		{
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				var position:Vector3D = modelMatrix.position;
				var value:Vector3D = new Vector3D(position.x, v/(rect.height*0.5), position.z);
				if(value.y != position.y)
				{
					modelMatrix.position = value;
					dirtyPrimitive();
				}
			}
			else
				_y = v;				
		}
		
		private var _position:Vector3D;
		public function get position():Vector3D
		{
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				var pt:Vector3D = modelMatrix.position;
				pt.x = (pt.x) * rect.width * 0.5;
				pt.y = (pt.y) * rect.height * 0.5;
				pt.z = 0;
				return pt;
			}
			else return null;
		}
		public function set position(v:Vector3D):void
		{
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				var pt:Vector3D = modelMatrix.position;
				v.z = pt.z;
				v.x = v.x / (rect.width*0.5);
				v.y = v.y / (rect.height*0.5);
				modelMatrix.position = v;
				dirtyPrimitive();
			}
			else
				_position = v;
		}
		
		public function getBoundsInWindowCoordinate(targetCoordinateSpace:PrimitiveNode = null):Rectangle
		{
			return null;
		}
		
		public function hitTestObject(obj:PrimitiveNode):Boolean
		{
			var vec:Vector3D = new Vector3D();
			var thisRect:Rectangle = this.getBoundsInWindowCoordinate();
			vec.x = thisRect.x;
			vec.y = thisRect.y;
			vec = this.localToGlobalInWindowCoordinate(vec);
			thisRect.x = vec.x;
			thisRect.y = vec.y;
			
			var objRect:Rectangle = obj.getBoundsInWindowCoordinate();
			vec.x = objRect.x;
			vec.y = objRect.y;
			vec = obj.localToGlobalInWindowCoordinate(vec);
			objRect.x = vec.x;
			objRect.y = vec.y;
			
			return thisRect.intersects(objRect);
		}
		
		public function hitTestPointInStageCoordinate(stageX:Number, stageY:Number, shapeFlag:Boolean = false):Boolean
		{
			var contain:Boolean = false;
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				var windowX:Number=(stageX / rect.width) * 2.0 - 1.0;
				var windowY:Number=(stageY / rect.height) * 2.0 - 1.0;
				
				var thisRect:Rectangle = this.getBoundsInWindowCoordinate(null);
				if(thisRect)contain = thisRect.contains(windowX, windowY);
			}
			return contain;
		}
		
		public function hitTestPointInWindowCoordinate(x:Number, y:Number, shapeFlag:Boolean = false):Boolean
		{
			var contain:Boolean = false;
			if(context)
			{
				var thisRect:Rectangle = this.getBoundsInWindowCoordinate(null);
				if(thisRect)contain = thisRect.contains(x, y);
			}
			return contain;
		}
		
		public function localToGlobalInWindowCoordinate(point:Vector3D):Vector3D
		{
			var worldMatrix:Matrix3D = getWorldMatrix();
			var result:Vector3D = worldMatrix.transformVector(point);
			return result;
		}
		
		public function globalToLocalInWindowCoordinate(point:Vector3D):Vector3D
		{
			var rootMatrix:Matrix3D = getWorldMatrix().clone();
			rootMatrix.invert();
			var result:Vector3D = rootMatrix.transformVector(point);
			return result;
		}
		
		public function globalToLocalInStageCoordinate(point:Vector3D):Vector3D
		{
			var result:Vector3D;
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				
				var rootMatrix:Matrix3D = getWorldMatrix().clone();
				rootMatrix.invert();
				
				point.x = point.x/(rect.width*0.5);
				point.y = point.y/(rect.height*0.5);
				
				result = rootMatrix.transformVector(point);
				
				result.x = result.x * rect.width*0.5;
				result.y = result.y * rect.height*0.5;
				result.z = 0;
			}
			return result;
		}
		
		public function localToGlobalInStageCoordinate(point:Vector3D):Vector3D
		{
			var result:Vector3D;
			if(context)
			{
				var worldMatrix:Matrix3D = getWorldMatrix();
				var rect:Rectangle = context.viewPort;
				
				point.x = point.x/(rect.width*0.5);
				point.y = point.y/(rect.height*0.5);
				
				result = worldMatrix.transformVector(point);
				
				result.x = result.x * rect.width*0.5;
				result.y = result.y * rect.height*0.5;
				result.z = 0;
			}
			return result;
		}
		
		public function addChild(child:PrimitiveNode):Boolean
		{
			return addChildAt(child, _children.length);
		}
		public function addChildAt(child:PrimitiveNode, index:uint):Boolean
		{
			if(_children.indexOf(child) != -1)return false;
			if(index > _children.length)index = _children.length;
			_children.splice(index, 0, child);
			child._parent = this;
			
			if(context)
			{
				child.updateContext(context, stage);
			}
			child.dirtyPrimitive();
			
			return true;
		}
		
		public function contains(child:PrimitiveNode):Boolean
		{
			for each(var node:PrimitiveNode in _children)
			{
				if(node == child)return true;
			}
			return false;
		}
		
		public function getChildAt(index:uint):PrimitiveNode
		{
			if(index >= _children.length || index < 0)return null;
			else return _children[index] as PrimitiveNode;
		}
		public function getChildByName(name:String):PrimitiveNode
		{
			for each(var node:PrimitiveNode in _children)
			{
				if(node.name == name)return node;
			}
			return null;
		}
		public function getChildIndex(child:PrimitiveNode):int
		{
			for(var i:int = 0; i < _children.length; i++)
			{
				if((_children[i] as PrimitiveNode) == child)return i;
			}
			return -1;
		}
		
		public function removeChild(child:PrimitiveNode):Boolean
		{
			if(child)
			{
				child._parent=null;
				child.updateContext(null,null);
				
				var i:int = _children.indexOf(child);
				if(i != -1)
				{
					_children.splice(i, 1);
					dirtyPrimitive();
					return true;
				}
			}
			return false;
		}
		
		public function removeChildAt(index:int):PrimitiveNode
		{
			var child:PrimitiveNode = getChildAt(index);
			removeChild(child);
			return child;
		}
		
		public function setChildIndex(child:PrimitiveNode, index:int):void
		{
			var i:int = _children.indexOf(child);
			if(i != -1)
			{
				_children.splice(i, 1);
				if(index > _children.length)index = _children.length;
				_children.splice(index, 0, child);
				dirtyPrimitive();
			}
		}

		public function swapChildren(child1:PrimitiveNode, child2:PrimitiveNode):void
		{
			var index1:int = _children.indexOf(child1);
			var index2:int = _children.indexOf(child2);
			if(index1 != -1 && index2 != -1)
			{
				_children[index1] =  child2;
				_children[index2] =  child1;
				dirtyPrimitive();
			}
		}
		
		public function swapChildrenAt(index1:int, index2:int):void
		{
			if(index1 >= _children.length && index2 >= _children.length)
			{
				var child1:PrimitiveNode = _children[index1] as PrimitiveNode;
				var child2:PrimitiveNode = _children[index2] as PrimitiveNode;
				_children[index1] =  child2;
				_children[index2] =  child1;
				dirtyPrimitive();
			}
		}
		
		public function getObjectUnderPointInWindowCoordinate(windowX:Number, windowY:Number, shapeFlag:Boolean, output:Array):void
		{
			//TODO: need to improve the performance
			if(hitTestPointInWindowCoordinate(windowX, windowY, shapeFlag))
			{
				output[output.length] = this;
			}
			for each(var node:PrimitiveNode in _children)
			{
				node.getObjectUnderPointInWindowCoordinate(windowX, windowY, shapeFlag, output);
			}
		}
		
		public function prerender(dest:DisplayContext3D):void
		{
			if (_visible)
			{
				for each(var child:PrimitiveNode in _children)
				{
					child.prerender(dest);
				}
			}
		}
		
		protected function dirtyPrimitive():void
		{
			if(!_primitiveDirty)
			{
				_primitiveDirty = true;
				for each(var child:PrimitiveNode in _children)
				{
					child.dirtyPrimitive();
				}
			}
		}
		
		protected function identity():void
		{
			modelMatrix.identity();
			dirtyPrimitive();
		}
		
		public function setPositionInWindowCoordinate(x:Number, y:Number, z:Number):void
		{
			modelMatrix.position = new Vector3D(x,y,z);
			dirtyPrimitive();
		}
		
		public function moveByInWindowCoordinate(dx:Number, dy:Number, dz:Number):void
		{
			modelMatrix.appendTranslation(dx, dy, dz);
			dirtyPrimitive();
		}
		
	/*	public function prependEulerRotationBy(xDegrees:Number, yDegrees:Number, zDegrees:Number):void
		{
			modelMatrix.prependRotation(xDegrees,Vector3D.X_AXIS); 
			modelMatrix.prependRotation(yDegrees,Vector3D.Y_AXIS); 
			modelMatrix.prependRotation(zDegrees,Vector3D.Z_AXIS);
			dirtyPrimitive();
		}
		
		public function appendEulerRotationBy(xDegrees:Number, yDegrees:Number, zDegrees:Number):void
		{
			modelMatrix.appendRotation(xDegrees,Vector3D.X_AXIS); 
			modelMatrix.appendRotation(yDegrees,Vector3D.Y_AXIS); 
			modelMatrix.appendRotation(zDegrees,Vector3D.Z_AXIS);
			dirtyPrimitive();
		}*/
		
		internal function getWorldMatrix():Matrix3D
		{
			updateWorldMatrix();
			return worldMatrix;
		}
		
		private function updateWorldMatrix():void
		{
			if (!_primitiveDirty) return;
			
			if (_parent) 
			{
				_parent.updateWorldMatrix();
				worldMatrix = _parent.worldMatrix.clone();				
			} 
			else 
			{
				worldMatrix = new Matrix3D();
				worldMatrix.identity();
			}
			worldMatrix.prepend (modelMatrix);
			_primitiveDirty = false;
		}
		
		internal function updateWorldSpacePosition():void
		{
			updateWorldMatrix();
			var temp : Vector.<Number> = new Vector.<Number>(4, true);
			temp[0] = 0; temp[1] = 0; temp[2] = 0; temp[3] = 1;
			worldMatrix.transformVectors (temp, worldPosition);
		}
		
		protected function setDefaultVertexMatrices(dest:DisplayContext3D, model:Matrix3D):void
		{
			//dest.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, model, true );
			//model.append (dest.view);
			//dest.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 8, model, true ); // modelview
			//model.append (dest.projection);
			//dest.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, model, true ); // modelviewprojection			
		}
		
		private function updateContext(context:DisplayContext3D, stage:Stage):void
		{
			this.context = context;
			this.stage = stage;
			for each(var node:PrimitiveNode in _children)
			{
				node.updateContext(context, stage);
			}
		}
	}
}