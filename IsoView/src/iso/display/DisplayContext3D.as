package iso.display
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public final class DisplayContext3D
	{
		public var triangleCount:uint;
		
		internal var context3D:Context3D;
		internal var viewProjection:Matrix3D;
		internal var depth:uint;

		internal var root:IDisplayStage;
		internal var camera:OrthoCamera;
		
		private var stage3D:Stage3D;
		private var program:Program3D;
		private var stage:Stage;
		
		private var quadMap:Dictionary;/*of <textureid, TextedMovie>*/
		private var quadInfoMap:Dictionary;/*of <textureid, BatchQuadInfo>*/
		
		private var gcPoint:int;
		
		public function DisplayContext3D(stage:Stage, stage3D:Stage3D, camera:OrthoCamera = null)
		{
			this.stage = stage;
			this.stage3D = stage3D;
			var rect:Rectangle = stage3D.viewPort;
			context3D=stage3D.context3D;
			context3D.configureBackBuffer(rect.width, rect.height, 1, false);
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			//context3D.enableErrorChecking = true;
			
			root=new DisplayStage3D(stage, this);
			root.startMouseAction();
			root.useShapeFlagInHitTest =true;
			
			if(!camera)
			{
				camera = new OrthoCamera();
				camera.moveByInWindowCoordinate(0,0,0);
			}
			setCamera(camera);
			
			quadInfoMap = new Dictionary();
		}
		
		private function setCamera(cam:OrthoCamera):void
		{
			this.camera=cam;
			camera.updateWorldSpacePosition();
			// setup the camera matrix parts, objects still need to set composite matrices (model and mvp)						
			viewProjection=camera.getWorldMatrix().clone();
			viewProjection.invert();
			var projection:Matrix3D=camera.getProjectionMatrix();
			viewProjection.append(projection);
		}

		public function get viewPort():Rectangle
		{
			return stage3D.viewPort;
		}

		public function render(dt:int):void
		{
			context3D.clear(1, 1, 1, 1);
			
			if (!camera)return;
			
			//prepare for GC, each GC for 10 times update.
			gcPoint++;
			var isNeedGc:Boolean = false;
			if(gcPoint > 10)
			{
				gcPoint = 0;
				isNeedGc = true;
			}

			triangleCount = 0;
			depth = 0;
			if(!program)buildProgram();
			
			//collect vetices for batch renderering.
			quadMap = new Dictionary();
			
			root.prerender(this);
			
			//prepare collections for GC counting.
			var usedQuadId:Dictionary
			if(isNeedGc)usedQuadId = new Dictionary();
			
			//batch renderering.
			for each(var list:Array in quadMap)
			{
				renderBatchedQuads(list, dt, usedQuadId);
			}
			
			//GC
			if(isNeedGc)
			{
				for(var texId:String in quadInfoMap)
				{
					if(!usedQuadId[texId])
					{
						usedQuadId[texId] = null;
						delete usedQuadId[texId];
					}
				}
			}
			
			context3D.present();
		}
		
		public function addQuadForBatch(batchId:String, quad:TexturedQuad, isVertexDirty:Boolean):void
		{
			var list:Array = quadMap[batchId];
			if(!list)
			{
				list = [];
				quadMap[batchId] = list;
				
			}
			var info:BatchQuadContext = quadInfoMap[batchId];
			if(!info)
			{
				info = new BatchQuadContext();
				quadInfoMap[batchId] = info;
			}
			
			info.isVertexDirty = info.isVertexDirty||isVertexDirty;
			
			list[list.length] = quad;
		}
		
		private function renderBatchedQuads(quadList:Array, dt:int, usedQuadId:Dictionary = null):void
		{
			if(quadList && quadList.length>0)
			{
				//prepare texture.
				var quad:TexturedQuad = quadList[0] as TexturedQuad;
				quad.bindTexture(this);
				
				var batchId:String = quad.getBatchId();
				if(usedQuadId)usedQuadId[batchId] = true;
				
				var info:BatchQuadContext = quadInfoMap[batchId];
				info.buildStream(quadList.length);
				
				for each(quad in quadList)
				{
					quad.batchRender(info, dt, info.isVertexDirty);
				}
				triangleCount+=info.triangleCount;
				info.buildBuffers(context3D);
			}
		}
		
		private function buildProgram():void
		{
			if (!program)
				program=context3D.createProgram();
			//va0: model position; va1: uv ;
			var vertextVerbose:String=
				"mov op, va0 \n"+
				"mov v0, va1";
			
			//TODO: add alpha/filter efect for the ftagment shader.
			var fragmentVerbose:String= 
				"mov ft0, v0			\n" +
				"tex ft1, ft0, fs0 <2d>	\n" +	// sample texture 0
				"mov oc, ft1";
			
			var vertex:AGALMiniAssembler=new AGALMiniAssembler;
			var fragment:AGALMiniAssembler=new AGALMiniAssembler;
			
			vertex.assemble(Context3DProgramType.VERTEX, vertextVerbose);
			fragment.assemble(Context3DProgramType.FRAGMENT, fragmentVerbose);
			
			program.upload(vertex.agalcode, fragment.agalcode);
			context3D.setProgram(program);
		}
		
		public function addChild(child:PrimitiveNode):Boolean
		{
			return root.addChild(child);
		}
		public function addChildAt(child:PrimitiveNode, index:uint):Boolean
		{
			return root.addChildAt(child, index);
		}
		public function contains(child:PrimitiveNode):Boolean
		{
			return root.contains(child);
		}
		public function getChildAt(index:uint):PrimitiveNode
		{
			return root.getChildAt(index);
		}
		public function getChildByName(name:String):PrimitiveNode
		{
			return root.getChildByName(name);
		}
		public function getChildIndex(child:PrimitiveNode):int
		{
			return root.getChildIndex(child);
		}
		public function removeChild(child:PrimitiveNode):Boolean
		{
			return root.removeChild(child);
		}
		public function removeChildAt(index:int):PrimitiveNode
		{
			return root.removeChildAt(index);
		}
		public function setChildIndex(child:PrimitiveNode, index:int):void
		{
			root.setChildIndex(child, index);
		}
		public function swapChildren(child1:PrimitiveNode, child2:PrimitiveNode):void
		{
			root.swapChildren(child1, child2);
		}
		public function swapChildrenAt(index1:int, index2:int):void
		{
			root.swapChildrenAt(index1, index2);
		}

	}
}