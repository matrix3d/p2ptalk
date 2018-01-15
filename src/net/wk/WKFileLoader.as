package net.wk 
{
	import debug.Log;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import lib3d.air.AIRUtils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class WKFileLoader extends WKURLLoader
	{
		private var isHttp:Boolean = false;
		public function WKFileLoader(request:URLRequest=null) 
		{
			super(request);
		}
		
		override public function load(request:URLRequest):void 
		{
			this.request = request;
			var ind:int=request.url.indexOf("http://")
			if (ind != 0){
				if (request.url.indexOf("app-storage:/")==0){
					var file:File =new File(request.url) //AIRUtils.newFile(request.url);
					request.url = file.nativePath;
				}
			}else{
				isHttp = true;
			}
			//处理下url 因为worker不能得到正确的存储目录
			//保存数据不用worker做 用这个类来做
			WorkerContext.instance.fileload(id, request.url, onComplete, onError, hasEventListener(ProgressEvent.PROGRESS)?onProgress:null,inflateNotOBJ);
		}
	}

}