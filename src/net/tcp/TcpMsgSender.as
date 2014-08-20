package net.tcp 
{
	import flash.net.Socket;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpMsgSender 
	{
		public var socket:Socket;
		public function TcpMsgSender(socket:Socket) 
		{
			this.socket = socket;
			
		}
		
		public function sendObject(data:Object):void {
			if(socket.connected){
				var bytes:ByteArray = new ByteArray;
				bytes.writeObject(data);
				socket.writeInt(bytes.length);
				socket.writeBytes(bytes, 0, bytes.length);
				socket.flush();
			}
		}
		
	}

}