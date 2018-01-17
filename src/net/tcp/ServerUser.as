package net.tcp 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ServerUser extends EventDispatcher{
		public static var ID:int = 1;
		public var id:int;
		public var socket:Socket;
		public var sender:TcpMsgSender;
		public var render:TcpMsgReader;
		public function listenerSocketClose():void {
			socket.addEventListener(Event.CLOSE, socket_close);
		}
		
		private function socket_close(e:Event):void 
		{
			dispatchEvent(e);
		}
	}

}