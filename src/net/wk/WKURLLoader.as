package net.wk 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class WKURLLoader extends URLLoader
	{
		public var request:URLRequest;
		protected var id:int = WorkerContext.ID++;
		//public var byte:ByteArray;
		protected var loading:Boolean = false;
		public var  inflateNotOBJ:Boolean = false;
		public function WKURLLoader(request:URLRequest=null) 
		{
			super(request);
		}
		
		override public function load(request:URLRequest):void 
		{
			this.request = request;
			loading = true;
			WorkerContext.instance.load(id, request.url, onComplete, onError, hasEventListener(ProgressEvent.PROGRESS)?onProgress:null,inflateNotOBJ);
		}
		
		protected function onProgress(a:int, b:int):void{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false,a, b));
		}
		protected function onError():void{
			loading = false;
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			WorkerContext.instance.closeLoad(id);
		}
		protected function onComplete(/*bid:int*/byte:ByteArray):void{
			loading = false;
			//byte = WorkerContext.instance.worker.getSharedProperty(bid + "") as ByteArray;
			//var byte2:ByteArray = new ByteArray;
			//byte2.writeBytes(byte);
			//byte2.position = 0;
			//byte = byte2;
			//this.byte = byte;
			data = byte//byte2;
			//data = byte;
			//WorkerContext.instance.worker.setSharedProperty(bid + "",undefined);
			dispatchEvent(new Event(Event.COMPLETE));
			WorkerContext.instance.closeLoad(id);
		}
		
		override public function close():void 
		{
			loading = false;
			//if (loading){
				//byte = null;
				data = null;
				WorkerContext.instance.closeLoad(id);
			//}
		}
	}

}