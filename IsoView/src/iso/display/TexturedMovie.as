package iso.display
{
	import flash.geom.Rectangle;

	public class TexturedMovie extends TexturedQuad
	{
		protected var _isTextureDirty:Boolean;
		
		private var _isPlaying:Boolean;
		private var _timeSinceLastUpdate:int;
		private var _animationDelay:int;
		
		public function TexturedMovie(clipData:TextureClipData, fps:int = 30)
		{
			super(clipData.textureData[0]);
			this.textures = clipData;
			this.fps = fps;
			_isTextureDirty = true;
		}
		
		private var _textures:TextureClipData;
		public function get textures():TextureClipData
		{
			return _textures;
		}
		public function set textures(value:TextureClipData):void
		{
			_textures = value;
			if(_textures && _textures.textureData)
			{
				_totalFrames = _textures.textureData.length;
			}
			else _totalFrames = 0;
		}
		
		private var _totalFrames:uint;
		public function get totalFrames():uint{return _totalFrames;}
		
		private var _fps:int;
		public function get fps():int{return _fps;}
		public function set fps(value:int):void
		{
			if (value <= 0)
			{
				_fps=0;
				_animationDelay=0;
			}
			else
			{
				_fps=value;
				_animationDelay=1000 / value;
			}
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		private var _currentFrame:int = 0;
		public function get currentFrame():int{return _currentFrame;}
		public function set currentFrame(value:int):void
		{
			_currentFrame = value;
			if(_currentFrame >= _totalFrames)_currentFrame=0;
			gotoFrameIndex(_currentFrame);
		}
		
		private var _autoDispose:Boolean;
		public function get autoDispose():Boolean{return _autoDispose;}
		public function set autoDispose(v:Boolean):void{_autoDispose = v;}
		
		public function randomFrame():void
		{
			currentFrame = Math.random()*totalFrames;
		}
		
		public function gotoFrameIndex(frameIndex:int):void
		{
			_currentFrame = frameIndex;
			var textureData:TextureData = _textures.textureData[frameIndex];
			if(textureData)
			{
				material.setupTextureData(textureData);
				_isTextureDirty = true;
			}
		}
		
		/*override public function prerender(dest:DisplayContext3D):void
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
				dest.addQuadMovieForBatch(textures.id, this, isNeedUpload, _isTextureDirty);
				
				isNeedUpload = false;
				_isTextureDirty = false;
				
				for each(var child:PrimitiveNode in _children)
				{
					child.prerender(dest);
				}
			}
		}*/
		override internal function getBatchId():String
		{
			return textures.id;
		}
		
		override internal function batchRender(batchContext:BatchQuadContext, dt:int, isBatchDirty:Boolean):void
		{
			if (_isPlaying)
			{
				_timeSinceLastUpdate+=dt;
				if (_timeSinceLastUpdate > _animationDelay)
				{
					_timeSinceLastUpdate-=_animationDelay;
					
					gotoFrameIndex(_currentFrame);
					_currentFrame++;
					if(_currentFrame >= _totalFrames)_currentFrame=0;
				}
			}
			super.batchRender(batchContext, dt, isBatchDirty);
		}
		
		public function play():void
		{
			if(textures && textures.textureData.length)
				_isPlaying=true;
		}
		
		public function stop():void
		{
			_isPlaying=false;
		}
	}
}