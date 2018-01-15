package net 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author lizhi
	 */
	public class URLMonitor extends EventDispatcher
	{
		private var req:URLRequest;
		private var loader:URLLoader;
		public var available:Boolean = false;
		public var pollInterval:int = 0;
		public function URLMonitor(req:URLRequest) 
		{
			this.req = req;
			loader = new URLLoader;
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			loader.addEventListener(ProgressEvent.PROGRESS, loader_progress);
			loader.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_complete(e:Event):void 
		{
			sendCompEvent();
		}
		
		private function loader_progress(e:ProgressEvent):void 
		{
			sendCompEvent();
		}
		
		private function sendCompEvent():void{
			removeAllListener();
			available = true;
			dispatchEvent(new StatusEvent(StatusEvent.STATUS));
		}
		
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			load();
		}
		
		private function removeAllListener():void{
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			loader.removeEventListener(ProgressEvent.PROGRESS, loader_progress);
			loader.removeEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function load():void{
			try{
				loader.close();
			}catch (err:Error){
				
			}
			loader.load(req);
		}
		
		public function start():void{
			load();
		}
		
		public function stop():void{
			try{
				loader.close();
			}catch (err:Error){
				
			}
			removeAllListener();
		}
		
	}

}