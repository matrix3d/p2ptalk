package net.socket {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import net.socket.SocketTransfer;
	/**
	 * 通过request得到网络资源，并传给请求socket
	 * @author lizhi
	 */
	public class ProxySocket 
	{
		private var socket:Socket;
		private var stream:URLStream;
		private var clientSocket:Socket;
		private var socketSender:Socket;
		private var sendPos:int = 0;
		private var st:SocketTransfer;
		public function ProxySocket(socket:Socket) 
		{
			this.socket = socket;
			socketSender = new Socket;
			st = new SocketTransfer(socket, Vector.<Socket>([socketSender]));
			st.addEventListener(ProgressEvent.SOCKET_DATA, st_socketData);
			var st2:SocketTransfer = new SocketTransfer(socketSender, Vector.<Socket>([socket]));
			st2.addEventListener(Event.CLOSE, st2_close);
			st_socketData(null);
		}
		
		private function st2_close(e:Event):void 
		{
			if (socket.connected) socket.close();
		}
		
		private function st_socketData(e:ProgressEvent):void 
		{
			st.bytes.position = 0;
			var txt:String = st.bytes.readMultiByte(st.bytes.length, "utf-8");
			trace(txt);
			var lines:Array = txt.split(/[\r\n]+/);
			for each(var line:String in lines) {
				var i:int = line.indexOf(" ");
				var key:String = line.substr(0, i).toLowerCase();
				var value:String = line.substr(i + 1);
				switch(key) {
					case "host:":
						var host:String = value;
						break;
				}
			}
			if (!socketSender.connected&&host) {
				var hosts:Array = host.split(":");
				socketSender.connect(hosts[0], hosts[1]?int(hosts[1]):80);
			}
		}
	}

}