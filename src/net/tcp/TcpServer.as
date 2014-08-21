package net.tcp 
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpServer
	{
		private static var serverSockets:Array = [];
		private var serverSocket:ServerSocket = new ServerSocket;
		private var users:Vector.<ServerUser> = new Vector.<ServerUser>;
		private var crossDomainServerSocket:ServerSocket;
		public var groups:Object = { };
		private static const crossDomainXML:XML=<cross-domain-policy>
		<allow-access-from domain="*" to-ports="*"/>
												</cross-domain-policy>
		public function TcpServer() 
		{
			serverSocket.bind(4444);
			serverSocket.listen();
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connect);
			serverSockets.push(serverSocket);
			
			crossDomainServerSocket = new ServerSocket;
			serverSockets.push(crossDomainServerSocket);
			crossDomainServerSocket.bind(843);
			crossDomainServerSocket.listen();
			crossDomainServerSocket.addEventListener(ServerSocketConnectEvent.CONNECT, crossDomainServerSocket_connect);
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
			var calbak:TcpServerReaderCalbak = new TcpServerReaderCalbak;
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
				suser.sender.sendObject(TcpConnecter.createMsg(data, TcpConnecter.MESSAGE, groupName, user.id));
			}
		}
	}

}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.Socket;
import net.tcp.TcpReaderCalbak
import net.tcp.TcpServer;
import net.tcp.TcpConnecter;
import net.tcp.TcpMsgSender;
import net.tcp.TcpMsgReader;
class TcpServerReaderCalbak extends TcpReaderCalbak {
	public var user:ServerUser;
	public var server:TcpServer;
	public function TcpServerReaderCalbak() {
		super(null);
	}
	override public function calbak(msg:Object):void 
	{
		var data:Object = msg[0];
		var type:int = msg[1];
		var groupName:String = msg[2];
		var userId:int = msg[3];
		switch(type) {
			case TcpConnecter.CREAT_GROUP:
				server.createGroup(groupName,user);
				break;
			case TcpConnecter.MESSAGE:
				server.sendTo(data, userId,groupName, user);
				break;
		}
	}
	
}

class ServerUser extends EventDispatcher{
	public static var ID:int = 0;
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