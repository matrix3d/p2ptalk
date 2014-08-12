package net.proxy {
	import net.socket.ProxySocket;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	/**
	 * ProxyServer2的资源服务器
	 * @author lizhi
	 */
	public class ProxyServer2AssetServer extends Sprite
	{
		private var mainsocket:Socket;
		
		public function ProxyServer2AssetServer() 
		{
			mainsocket = new Socket("192.168.3.207", 9875);
			mainsocket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
		}
		
		private function socket_socketData(e:ProgressEvent):void 
		{
			var socket:Socket = e.currentTarget as Socket;
			while (socket.bytesAvailable) {
				socket.readByte();
				var csocket:Socket = new Socket("192.168.3.207", 9874);
				csocket.addEventListener(ProgressEvent.SOCKET_DATA, csocket_socketData);
			}
		}
		
		private function csocket_socketData(e:ProgressEvent):void 
		{
			var socket:Socket = e.currentTarget as Socket;
			new ProxySocket(socket);
		}
		
	}

}