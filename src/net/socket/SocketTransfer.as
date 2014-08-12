package net.socket 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	/**
	 * socket传输者，将一个socket数据完全传输给其它socket
	 * @author lizhi
	 */
	public class SocketTransfer extends EventDispatcher
	{
		private var from:Socket;
		private var tos:Vector.<Socket>;
		private var tosPos:Vector.<int>;
		private var log:Function;
		public var bytes:ByteArray;
		public function SocketTransfer(from:Socket,tos:Vector.<Socket>,log:Function=null) 
		{
			this.log = log;
			this.tos = tos;
			this.from = from;
			tosPos = new Vector.<int>(tos.length);
			bytes = new ByteArray;
			from_socketData(null);
			from.addEventListener(ProgressEvent.SOCKET_DATA, from_socketData);
			from.addEventListener(IOErrorEvent.IO_ERROR, from_ioError);
			from.addEventListener(Event.CLOSE, from_close);
			from.addEventListener(Event.CONNECT, from_connect);
			for each(var to:Socket in tos) {
				to.addEventListener(Event.CONNECT, to_connect);
			}
		}
		
		private function from_connect(e:Event):void 
		{
			from_socketData(null);
		}
		
		private function from_ioError(e:IOErrorEvent):void 
		{
			from_close(null);
		}
		
		private function from_close(e:Event):void 
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function to_connect(e:Event):void 
		{
			from_socketData(null);
		}
		
		private function from_socketData(e:ProgressEvent):void 
		{
			if(from.connected){
				var bytesAvailable:int = from.bytesAvailable;
				bytes.position = bytes.length;
				while (from.bytesAvailable) {
					bytes.writeByte(from.readByte());
				}
				for (var i:int = 0; i < tos.length;i++ ) {
					var to:Socket = tos[i];
					if (to.connected) {
						var pos:int = tosPos[i];
						to.writeBytes(bytes, pos, bytes.length - pos);
						tosPos[i] = bytes.length;
						to.flush();
					}
				}
				if (bytesAvailable) {
					dispatchEvent(new ProgressEvent(ProgressEvent.SOCKET_DATA));
				}
			}
		}
		
	}

}