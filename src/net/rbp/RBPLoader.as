package net.rbp 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class RBPLoader extends EventDispatcher
	{
		public var start:int;
		public static var PROGRESS:String = "rbpPROGRESS";
		public var loader:RangeLoader// = new RangeLoader;
		public var decoder:RBPDecoder = new RBPDecoder(null, true);
		public function RBPLoader() 
		{
			//loader.addEventListener(ProgressEvent.PROGRESS, loader_progress);
			//loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			//loader.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function loader_complete(e:Event):void 
		{
			loader_progress(null);
			dispatchEvent(e);
		}
		
		private function loader_progress(e:ProgressEvent):void 
		{
			if(e&&e.currentTarget==loader){
				dispatchEvent(new ProgressEvent(e.type,false,false,e.bytesLoaded+loader.start,e.bytesTotal+loader.start));
			}
			while (decoder.readLine()){
				if (e.currentTarget!=loader){
					break;
				}
				//if(decoder.stats==0)
				dispatchEvent(new ProgressEvent(PROGRESS));
			}
		}
		
		public function load(url:String, start:int):void{
			this.start = start;
			if (loader){
				loader.removeEventListener(ProgressEvent.PROGRESS, loader_progress);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
				loader.removeEventListener(Event.COMPLETE, loader_complete);
				try{
					loader.close();
				}catch (err:Error){
					
				}
				loader = null;
			}
			loader = new RangeLoader;
			decoder.setByte(loader);
			decoder.position = start;
			loader.addEventListener(ProgressEvent.PROGRESS, loader_progress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			loader.addEventListener(Event.COMPLETE, loader_complete);
			loader.loadRange(new URLRequest(url), start);
			//loader.load(new URLRequest(url));
		}
	}

}