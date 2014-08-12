package net.proxy  
{
	import flash.display.Sprite;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	import net.socket.ProxySocket;
	/**
	 * air代理服务器 直接用过air socket 读取网络资源 传给浏览器
	 * @author lizhi
	 */
	public class ProxyServer extends Sprite
	{
		private var serverSocket:ServerSocket;
		public function ProxyServer() 
		{
			serverSocket = new ServerSocket;
			serverSocket.bind(9876);
			serverSocket.listen();
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connect);
		}
		
		private function serverSocket_connect(e:ServerSocketConnectEvent):void 
		{
			new ProxySocket(e.socket);
		}
	}

}