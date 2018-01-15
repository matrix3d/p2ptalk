package net.rbp2 
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class RangeLoader extends URLStream
	{
		public var start:int;
		public var byte:ByteArray;
		public function RangeLoader() 
		{
			//addEventListener(ProgressEvent.PROGRESS, progress);
		}
		
		//private function progress(e:ProgressEvent):void 
		//{
		//}
		
		public function loadRange(request:URLRequest,start:int,end:uint=0x7fffffff):void 
		{
			this.start = start;
			var header:URLRequestHeader = new URLRequestHeader("Range", "bytes=" + start + "-" + end);
			request.requestHeaders.push(header);
			super.load(request);
		}
		
	}

}