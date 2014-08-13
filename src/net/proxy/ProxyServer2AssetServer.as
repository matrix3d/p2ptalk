package net.proxy {
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
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
		private var info:TextField = new TextField;
		public function ProxyServer2AssetServer() 
		{
			addChild(info);
			mainsocket = new Socket("192.168.3.207", 9875);
			mainsocket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
			mainsocket.addEventListener(IOErrorEvent.IO_ERROR, mainsocket_ioError);
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, timer_timer);
			timer.start();
		}
		
		private function mainsocket_ioError(e:IOErrorEvent):void 
		{
			timer_timer(null);
		}
		
		private function timer_timer(e:TimerEvent):void 
		{
			if (!mainsocket.connected) {
				mainsocket.connect("192.168.3.207",9875);
			}
			info.text = mainsocket.connected+"";
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