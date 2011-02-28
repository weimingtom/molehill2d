package iso.display
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public final class OrthoCamera extends PrimitiveNode
	{
		internal var zNear:Number;
		internal var zFar:Number;

		internal var projectionMatrix:Matrix3D;

		public function OrthoCamera(zNear:Number=0.02,zFar:Number=1)
		{
			this.zNear=zNear;
			this.zFar=zFar;
			updateProjectionMatrix();
		}

		override public function get position():Vector3D
		{
			return modelMatrix.position;
		}
		override public function set position(v:Vector3D):void
		{
			modelMatrix.position = v;
			dirtyPrimitive();
		}
		
		public function getProjectionMatrix():Matrix3D
		{
			updateProjectionMatrix();
			return projectionMatrix;
		}

		private function updateProjectionMatrix():void
		{
			projectionMatrix=makeOrthographicMatrix(-1, 1, -1, 1, zNear, zFar);
		}

		private function makeOrthographicMatrix(left:Number, right:Number, top:Number, bottom:Number, zNear:Number, zFar:Number):Matrix3D
		{
			var data:Vector.<Number>=new Vector.<Number>(16);
			data[0]=2/(right - left);
			data[1]=0;
			data[2]=0;
			data[3]=-(right + left) / (right - left);
			
			data[4]=0;
			data[5]=2/ (top - bottom);
			data[6]=0;
			data[7]=(top + bottom) / (top - bottom);
			
			data[8]=0;
			data[9]=0;
			data[10]=1 / (zNear - zFar);
			data[11]=-zNear/(zFar - zNear);
			
			data[12]=0;
			data[13]=0;
			data[14]=0;
			data[15]=1;
			return new Matrix3D(data);
		}
		
		private function makePerspecativeMatrix(left:Number, right:Number, top:Number, bottom:Number, zNear:Number, zFar:Number):Matrix3D
		{
			var data:Vector.<Number>=new Vector.<Number>(16);
			data[0]=(2 * zNear) / (right - left);
			data[1]=0;
			data[2]=(right + left) / (right - left);
			data[3]=0;

			data[4]=0;
			data[5]=(2 * zNear) / (top - bottom);
			data[6]=(top + bottom) / (top - bottom);
			data[7]=0;

			data[8]=0;
			data[9]=0;
			data[10]=zFar / (zNear - zFar);
			data[11]=-1;

			data[12]=0;
			data[13]=0;
			data[14]=(zNear * zFar) / (zNear - zFar);
			data[15]=0;
			return new Matrix3D(data);
		}

	}
}