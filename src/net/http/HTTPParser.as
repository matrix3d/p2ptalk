package net.http 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPParser extends EventDispatcher
	{
		public var header:String = "";
		public var headerObj:Object;
		public var headerOver:Boolean = false;
		public var contentOver:Boolean = false;
		public var content:String = "";
		private var _n:int = 0;
		private var socket:Socket;
		private var len:int = 0;
		private var hlen:int;
		private var clen:int;
		public function HTTPParser(socket:Socket) 
		{
			this.socket = socket;
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
		}
		
		private function socket_socketData(e:ProgressEvent):void 
		{
			len += socket.bytesAvailable;
			var d:String = socket.readUTFBytes(socket.bytesAvailable);
			var len:int = d.length;
			for (var i:int = 0; i < len; i++ ){
				var c:String = d.charAt(i);
				if (headerOver){
					content += c;
				}else{
					header += c;
				}
				if (c=="\n"){
					_n++;
					if (_n > 1){
						if(!headerOver){
							//trace("header\n",header);
							var by:ByteArray = new ByteArray;
							by.writeUTFBytes(header);
							headerOver = true;
							headerObj = (new HTTPHeader(header)).obj;
							clen=int(headerObj["Content-Length"]);
						}
					}
				}else if (c == "\r"){
				}else{
					_n = 0;
				}
			}
			if ((hlen+clen)<=len){
				contentOver = true;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}

}