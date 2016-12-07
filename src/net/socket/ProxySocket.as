package net.socket {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;
	import net.http.HTTPParser;
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
		private var st2:SocketTransfer;
		public function ProxySocket(socket:Socket) 
		{
			this.socket = socket;
			socketSender = new Socket;
			st = new SocketTransfer(socket, Vector.<IDataOutput>([socketSender]));
			st.addEventListener(ProgressEvent.SOCKET_DATA, st_socketData);
			st2 = new SocketTransfer(socketSender, Vector.<IDataOutput>([socket]));
			st2.addEventListener(Event.CLOSE, st2_close);
			st2.addEventListener(ProgressEvent.SOCKET_DATA, st2_socketData);
			st_socketData(null);
		}
		
		private function st2_socketData(e:ProgressEvent):void 
		{
			/*var fs:FileStream = new FileStream;
			fs.open(File.desktopDirectory.resolvePath("proxy4/" + Math.random()), FileMode.WRITE);
			st2.bytes.position = 0;
			fs.writeBytes(st2.bytes);
			fs.close();*/
		}
		
		private function st2_close(e:Event):void 
		{
			if (socket.connected) {
				socket.close();
			}
		}
		
		private function st_socketData(e:ProgressEvent):void 
		{
			st.bytes.position = 0;
			var parser:HTTPParser = new HTTPParser(null);
			parser.parser(st.bytes);
			if (parser.headerOver){
				var host:String = parser.headerObj.Host;
				if (!socketSender.connected&&host) {
					var hosts:Array = host.split(":");
					socketSender.connect(hosts[0], hosts[1]?int(hosts[1]):80);
				}
			}
		}
	}

}