package net.tcp
{
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpMsgReader
	{
		
		private var waitLength:int = -1;
		private var socket:Socket;
		private var calbak:TcpReaderCalbak;
		
		public function TcpMsgReader(socket:Socket, calbak:TcpReaderCalbak)
		{
			this.calbak = calbak;
			this.socket = socket;
		
			socket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
			read();
		}
		
		private function socket_socketData(e:ProgressEvent):void 
		{
			read();
		}
		
		private function socket_ioError(e:IOErrorEvent):void 
		{
			
		}
		
		public function read():void
		{
			if(socket.connected)
			if (waitLength == -1)
			{
				if (socket.bytesAvailable >= 4)
				{
					waitLength = socket.readInt();
					read();
				}
			}
			else
			{
				if (socket.bytesAvailable >= waitLength)
				{
					var data:Object = socket.readObject();
					calbak.calbak(data);
					waitLength = -1;
					read();
				}
			}
		}
	
	}

}