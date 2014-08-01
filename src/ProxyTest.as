package  
{
	import flash.display.Sprite;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ProxyTest extends Sprite
	{
		private var serverSocket:ServerSocket;
		
		public function ProxyTest() 
		{
			serverSocket = new ServerSocket;
			serverSocket.bind(9876);
			serverSocket.listen();
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connect);
		}
		
		private function serverSocket_connect(e:ServerSocketConnectEvent):void 
		{
			e.socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
			e.socket.writeMultiByte("123\n", "utf-8");
			e.socket.flush();
			//e.socket.close();
		}
		
		private function socket_socketData(e:ProgressEvent):void 
		{
			var s:Socket = e.currentTarget as Socket;
			var b:ByteArray = new ByteArray;
			trace(s.readBytes(b, 0, s.bytesAvailable));
			s.close();
		}
		
	}

}