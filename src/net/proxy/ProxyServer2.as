package net.proxy {
	import flash.display.Sprite;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	import net.proxy.ProxyServer2AssetServer;
	import net.socket.SocketTransfer;
	/**
	 * air代理服务器，和一个可以上网的机器开通通道，并给本机上网
	 * @author lizhi
	 */
	public class ProxyServer2 extends Sprite
	{
		//作为请求资源的通道，每当需要一个socket请求之
		private var mainServerSocket:ServerSocket;
		private var mainSocket:Socket;
		
		//代理服务器，和浏览器交互
		private var serverSocket:ServerSocket;
		
		//客户端服务器，和可以上网的机器进行交互
		private var clientSocket:ServerSocket;
		
		private var waits:Array = [];
		public function ProxyServer2() 
		{
			mainServerSocket = new ServerSocket;
			mainServerSocket.bind(9875);
			mainServerSocket.listen();
			mainServerSocket.addEventListener(ServerSocketConnectEvent.CONNECT, mainServerSocket_connect);
			
			clientSocket = new ServerSocket;
			clientSocket.bind(9874);
			clientSocket.listen();
			clientSocket.addEventListener(ServerSocketConnectEvent.CONNECT, clientSocket_connect);
			
			
			serverSocket = new ServerSocket;
			serverSocket.bind(9876);
			serverSocket.listen();
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connect);
			
			//new ProxyServer2AssetServer();
		}
		
		private function clientSocket_connect(e:ServerSocketConnectEvent):void 
		{
			if (waits.length) {
				var socket:Socket = waits.shift();
				new SocketTransfer(e.socket, Vector.<Socket>([socket]));
				new SocketTransfer(socket, Vector.<Socket>([e.socket]));
			}
		}
		
		
		private function mainServerSocket_connect(e:ServerSocketConnectEvent):void 
		{
			mainSocket = e.socket;
		}
		
		private function serverSocket_connect(e:ServerSocketConnectEvent):void 
		{
			if(mainSocket&&mainSocket.connected){
				waits.push(e.socket);
				mainSocket.writeByte(1);//一旦有链接，即请求一个socket
				mainSocket.flush();
			}
		}
		
	}

}