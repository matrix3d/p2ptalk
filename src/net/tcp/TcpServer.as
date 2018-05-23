package net.tcp 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpServer extends EventDispatcher
	{
		private static var serverSockets:Array = [];
		private var serverSocket:ServerSocket = new ServerSocket;
		public var users:Vector.<ServerUser> = new Vector.<ServerUser>;
		private var crossDomainServerSocket:ServerSocket;
		public var groups:Object = { };
		private static const crossDomainXML:XML=<cross-domain-policy>
		<allow-access-from domain="*" to-ports="*"/>
												</cross-domain-policy>;
		private var calbak:TcpServerReaderCalbak;
		public function TcpServer(port:int,calbak:TcpServerReaderCalbak=null) 
		{
			this.calbak = calbak;
			try{
			serverSocket.bind(port);
			serverSocket.listen();
			}catch (err:Error){
				trace(err.getStackTrace());
			}
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connect);
			serverSocket.addEventListener(Event.CLOSE, serverSocket_close);
			serverSockets.push(serverSocket);
			
			crossDomainServerSocket = new ServerSocket;
			serverSockets.push(crossDomainServerSocket);
			try{
			crossDomainServerSocket.bind(843);
			crossDomainServerSocket.listen();
			}catch (err:Error){
				trace(err.getStackTrace());
			}
			crossDomainServerSocket.addEventListener(ServerSocketConnectEvent.CONNECT, crossDomainServerSocket_connect);
		}
		
		private function serverSocket_close(e:Event):void 
		{
			dispatchEvent(e);
		}
		
		private function crossDomainServerSocket_connect(e:ServerSocketConnectEvent):void 
		{
			e.socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketData);
		}
		
		private function socket_socketData(e:ProgressEvent):void 
		{
			var socket:Socket = e.currentTarget as Socket;
			trace(socket.readMultiByte(socket.bytesAvailable,"utf-8"));
			socket.writeMultiByte(crossDomainXML + "\r", "utf-8");
			socket.flush();
			socket.close();
		}
		
		private function serverSocket_connect(e:ServerSocketConnectEvent):void 
		{
			var user:ServerUser = new ServerUser;
			user.addEventListener(Event.CLOSE, user_close);
			user.id = ServerUser.ID++;
			user.sender = new TcpMsgSender(e.socket);
			user.socket = e.socket;
			user.listenerSocketClose();
			var calbak:TcpServerReaderCalbak = this.calbak||new TcpServerReaderCalbak;
			calbak.user = user;
			calbak.server = this;
			user.render = new TcpMsgReader(e.socket, calbak);
			users.push(user);
		}
		
		private function user_close(e:Event):void 
		{
			var user:ServerUser = e.currentTarget as ServerUser;
			for (var name:String in groups) {
				var g:Array = groups[name]
				var i:int = g.indexOf(user);
				if (i!=-1) {
					g.splice(i, 1);
					for each(var u:ServerUser in g) {
						u.sender.sendObject(TcpConnecter.createMsg(null, TcpConnecter.REMOVE_USER, name, user.id));
					}
				}
			}
		}
		
		public function createGroup(name:String,user:ServerUser):void {
			var group:Array = groups[name];
			if (group==null) {
				group=groups[name] = [];
			}
			for (var i:int = 0; i < group.length ; i++ ) {
				var suser:ServerUser = group[i];
				user.sender.sendObject(TcpConnecter.createMsg(null,TcpConnecter.ADD_USER,name,suser.id));
				suser.sender.sendObject(TcpConnecter.createMsg(null,TcpConnecter.ADD_USER,name,user.id));
			}
			group.push(user);
		}
		
		private function getUser(id:int):ServerUser {
			for each(var user:ServerUser in users) {
				if (user.id==id) {
					return user;
				}
			}
			return null;
		}
		
		public function sendTo(data:Object,userId:int,groupName:String,user:ServerUser):void {
			var suser:ServerUser = getUser(userId);
			if (suser) {
				suser.sender.sendObject(TcpConnecter.createMsg(data, TcpConnecter.MESSAGE, groupName, user?user.id:0));
			}
		}
		public function post(data:Object,groupName:String,user:ServerUser):void {
			for each(var suser:ServerUser in users){
				sendTo(data, suser.id, groupName, user);
			}
		}
	}

}



