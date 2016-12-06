package net.http 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import net.event.HTTPEvent;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPLoader extends EventDispatcher
	{
		private var hurl:URL;
		private var req:HTTPRequest;
		protected var socket:Socket;
		public var parser:HTTPParser;
		public function HTTPLoader() 
		{
			
		}
		
		public function load(url:String):void{
			hurl = new URL(url);
			req = new HTTPRequest(hurl);
			socket = new Socket(hurl.host, hurl.port);
			parser = new HTTPParser(socket);
			parser.addEventListener(Event.CHANGE, parser_change);
			socket.addEventListener(Event.CONNECT, socket_connect);
			socket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
			socket.addEventListener(Event.CLOSE, socket_close);
		}
		
		protected function parser_change(e:Event):void 
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			if (parser.headerOver){
				dispatchEvent(new HTTPEvent(HTTPEvent.HEADER_COMPLETE));
			}
			if (parser.contentOver){
				dispatchEvent(new HTTPEvent(HTTPEvent.COMPLETE));
				if(socket.connected){
					socket.close();
				}
			}
		}
		
		private function socket_close(e:Event):void 
		{
			trace(e);
		}
		
		private function socket_ioError(e:IOErrorEvent):void 
		{
			trace(e);
		}
		
		private function socket_socketData(e:ProgressEvent):void 
		{
		}
		
		private function socket_connect(e:Event):void 
		{
			socket.writeUTFBytes(req.req);
		}
		
	}

}