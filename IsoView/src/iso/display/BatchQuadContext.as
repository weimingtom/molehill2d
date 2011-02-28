package iso.display
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;

	public final class BatchQuadContext
	{
		private var indexBuffer:IndexBuffer3D;
		private var vertexBuffer:VertexBuffer3D;
		
		public var indexStream:Vector.<uint>;
		public var vertexStream:Vector.<Number>;
		
		public var isVertexDirty:Boolean;
		public var isMaterialDirty:Boolean;
		
		public var triangleCount:uint;
		
		public var position:uint;
		
		public function BatchQuadContext()
		{
		}
		
		public function buildStream(numOfQuads:uint):void
		{
			if(isVertexDirty)
			{
				//TODO: build new vectors each time or re-use previous one?
				indexStream = new Vector.<uint>(numOfQuads*6, true);
				vertexStream = new Vector.<Number>(numOfQuads*20, true);
				position = 0;
			}
		}
		public function buildBuffers(context3D:Context3D):void
		{
			if(isVertexDirty)
			{
				indexBuffer=context3D.createIndexBuffer(indexStream.length);
				vertexBuffer=context3D.createVertexBuffer(vertexStream.length, 5);
				
				var vertices:uint = vertexStream.length/5;
				vertexBuffer.uploadFromVector(vertexStream, 0, vertices);
				
				var j:int = 0;
				for(var i:int = 0; i < vertices; i+=6, j+=4)
				{
					indexStream[i] = 0+j;
					indexStream[i+1] = 1+j;
					indexStream[i+2] = 2+j;
					indexStream[i+3] = 0+j;
					indexStream[i+4] = 2+j;
					indexStream[i+5] = 3+j;
				}
				indexBuffer.uploadFromVector(indexStream, 0, indexStream.length);
				
				isVertexDirty = false;
			}
			
			triangleCount = indexStream.length/3;
			
			context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3); //position
			context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2); //uv
			context3D.drawTriangles(indexBuffer, 0, triangleCount);
		}
		
	}
}