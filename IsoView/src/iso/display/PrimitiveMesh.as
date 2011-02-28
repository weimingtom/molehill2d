package iso.display
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	public class PrimitiveMesh extends PrimitiveNode implements IDisplayPrimitive
	{
		private static const ZERO_POINT:Point = new Point();
		
		public var material:Material;

		protected var vertexStream:Vector.<Number>;
		protected var isNeedUpload:Boolean;

		protected var boundingbox:Vector.<Number>; // object space axis aligned, min(x,y,z) - max(x,y,z) 
		protected var boundingsphereradius:Number=0; // object space, centered around origin				

		protected var _geometryDirty:Boolean;
		protected var indexLength:uint = 6;

		public function PrimitiveMesh(material:Material)
		{
			this.material=material;
			isNeedUpload=true;
		}

		override public function dispose():void
		{
			if(material)material.dispose();
			super.dispose();
		}
		
		protected var _rawWidth:Number;
		public function get rawWidth():Number
		{
			return _rawWidth;
		}
		public function set rawWidth(value:Number):void
		{
			_rawWidth = value;
		}
		
		protected var _rawHeight:Number;
		public function get rawHeight():Number
		{
			return _rawHeight;
		}
		public function set rawHeight(value:Number):void
		{
			_rawHeight = value;
		}
		
		
		protected var _width:Number = 100;
		public function get width():Number
		{
			return _width;
		}
		public function set width(val:Number):void
		{
			if (_width == val)
				return;
			
			_width = val;
			_geometryDirty = true;
		}
		
		protected var _height:Number = 100;
		public function get height():Number
		{
			return _height;
		}
		public function set height(val:Number):void
		{
			if (_height == val)
				return;
			
			_height = val;
			_geometryDirty = true;
		}
		
		
		protected var _alpha:Number = 1;
		public function get alpha():Number
		{
			return _alpha;
		}
		public function set alpha(v:Number):void
		{
			if(_alpha != v && v >= 0 && v <= 1)
			{
				_alpha = v;
				material.setAlpha(v);
			}
		}
		
		protected var _filter:BitmapFilter;
		public function get filter():BitmapFilter
		{
			return _filter;
		}
		public function set filter(v:BitmapFilter):void
		{
			if(_filter != v)
			{
				_filter = v;
				material.filter = v;
			}
		}
		
		protected var _scaleX:Number = 1;
		public function get scaleX():Number
		{
			return _scaleX;
		}
		public function set scaleX(v:Number):void
		{
			if(!isNaN(v))
			{
				_scaleX = v;
				modelMatrix.appendScale(v,1,1);
				dirtyPrimitive();
			}
		}
		
		protected var _scaleY:Number = 1;
		public function get scaleY():Number
		{
			return _scaleY;
		}
		public function set scaleY(v:Number):void
		{
			if(!isNaN(v))
			{
				_scaleY = v;
				modelMatrix.appendScale(1,v,1);
				dirtyPrimitive();
			}
		}
		
		public function set scale(v:Number):void
		{
			if(!isNaN(v))
			{
				_scaleY = _scaleX = v;
				modelMatrix.appendScale(v,v,1);
				dirtyPrimitive();
			}
		}
		
		override public function hitTestPointInStageCoordinate(stageX:Number, stageY:Number, shapeFlag:Boolean = false):Boolean
		{
			var contain:Boolean;
			if(context)
			{
				var rect:Rectangle = context.viewPort;
				var windowX:Number=(stageX / rect.width) * 2.0 - 1.0;
				var windowY:Number=(stageY / rect.height) * 2.0 - 1.0;
				
				var thisRect:Rectangle = this.getBoundsInWindowCoordinate(null);
				contain = thisRect.contains(windowX, windowY);
				if(contain && shapeFlag)
				{
					var bitmap:BitmapData = material.getBitmapData();
					if(bitmap)
					{
						var coordinate:Vector3D = new Vector3D(windowX,windowY);
						coordinate = globalToLocalInWindowCoordinate(coordinate);
						var point:Point = new Point(coordinate.x * bitmap.width, coordinate.y * bitmap.height);
						contain = bitmap.hitTest(ZERO_POINT, 0, point);
					}
					else 
					{
						return false;
					}
				}
				else
				{
					return false;
				}
			}
			return contain;
		}
		override public function hitTestPointInWindowCoordinate(x:Number, y:Number, shapeFlag:Boolean = false):Boolean
		{
			var contain:Boolean;
			if(context)
			{
				var thisRect:Rectangle = this.getBoundsInWindowCoordinate(null);
				contain = thisRect.contains(x, y);
				if(contain && shapeFlag)
				{
					var bitmap:BitmapData = material.getBitmapData();
					if(bitmap)
					{
						var coordinate:Vector3D = new Vector3D(x,y);
						coordinate = globalToLocalInWindowCoordinate(coordinate);
						var point:Point = new Point(coordinate.x * bitmap.width, coordinate.y * bitmap.height);
						contain = bitmap.hitTest(ZERO_POINT, 0, point);
					}
					else 
					{
						return false;
					}
				}
				else
				{
					return false;
				}
			}
			return contain;
		}
		
		protected function computeBoundingBox():void
		{
			if (vertexStream == null || vertexStream.length < 4)
			{
				boundingbox=null;
				return;
			}
			boundingbox=new Vector.<Number>(5, true);
			boundingbox[0]=vertexStream[0];
			boundingbox[1]=vertexStream[1];
			boundingbox[2]=0;
			boundingbox[3]=vertexStream[0];
			boundingbox[4]=vertexStream[1];
			for (var o:uint=5; o < vertexStream.length; o+=5)
			{
				if (vertexStream[o + 0] < boundingbox[0])boundingbox[0]=vertexStream[o + 0];
				if (vertexStream[o + 1] < boundingbox[1])boundingbox[1]=vertexStream[o + 1];
					
				if (vertexStream[o + 0] > boundingbox[3])boundingbox[3]=vertexStream[o + 0];
				if (vertexStream[o + 1] > boundingbox[4])boundingbox[4]=vertexStream[o + 1];
			}
			boundingsphereradius=0;
			for (var i:uint; i < 4; i++)
			{
				var x:Number=boundingbox[(i & 1) == 0 ? 0 : 3];
				var y:Number=boundingbox[(i & 2) == 0 ? 1 : 4];
				var d:Number=x * x + y * y;
				if (d > boundingsphereradius)
					boundingsphereradius=d;
			}
			boundingsphereradius=Math.sqrt(boundingsphereradius);
		}

		protected function isboundingBoxVisibleInClipspace(mvp:Matrix3D, bounds:Vector.<Number>):Boolean
		{
			// just transform 4 vertices to clipspace, then check if they are completly clipped

			var rawm:Vector.<Number>=mvp.rawData;

			var outsidebits:uint=(1 << 4) - 1;

			for (var i:uint=0; i < 4; i++)
			{
				var x:Number=boundingbox[(i & 1) == 0 ? 0 : 3];
				var y:Number=boundingbox[(i & 2) == 0 ? 1 : 4];
				// transform
				var xcs:Number=x * rawm[0] + y * rawm[4] + rawm[12];
				var ycs:Number=x * rawm[1] + y * rawm[5] + rawm[13];
				var wcs:Number=x * rawm[3] + y * rawm[7] + rawm[15];
				// check clipping				
				if (xcs >= -wcs)
					outsidebits&=~(1 << 0); // no longer all are outside -x ... clear -x bit.. etc
				if (xcs <= wcs)
					outsidebits&=~(1 << 1);
				if (ycs >= -wcs)
					outsidebits&=~(1 << 2);
				if (ycs <= wcs)
					outsidebits&=~(1 << 3);
			}
			if (outsidebits != 0)
				return false;
			return true;
		}
		
	}
}