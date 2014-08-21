package net.tcp 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import net.Connecter;
	import net.Group;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpConnecter extends Connecter
	{
		public static const CREAT_GROUP:int = 1;
		public static const ADD_USER:int = 2;
		public static const REMOVE_USER:int = 3;
		public static const MESSAGE:int = 4;
		
		private var host:String;
		private var port:int;
		private var socket:Socket;
		private var sender:TcpMsgSender
		private var reader:TcpMsgReader
		private var readerCalbak:TcpReaderCalbak
		public function TcpConnecter(host:String,port:int) 
		{
			this.port = port;
			this.host = host;
			readerCalbak = new TcpReaderCalbak(this);
			
			try {
				Security.allowDomain("*");
			}catch (err:Error) {
				
			}
			
		}
		
		override public function start():void {
			if (socket == null) {
				socket = new Socket;
				reader = new TcpMsgReader(socket, readerCalbak);
				sender = new TcpMsgSender(socket);
				socket.addEventListener(Event.CONNECT, socket_connect);
			}
			socket.connect(host, port);
		}
		
		override public function createGroupByName(name:String):Group {
			var group:TcpGroup = new TcpGroup;
			group.name = name;
			group.tcpSender = sender;
			return group;
		}
		
		override public function startGroup(group:Group):void {
			group.connnecter = this;
			groups.push(group);
			sender.sendObject(createMsg(null, CREAT_GROUP,group.name,-1));
			group.connectSuccess();
		}
		
		public static function createMsg(data:Object, type:int,groupName:String,userId:int):Object {
			return [data,type,groupName,userId]
		}
		
		override public function stop():void {
			if (socket) socket.close();
		}
		
		private function socket_connect(e:Event):void 
		{
			connectSuccess();
		}
		
		public function addUserMsg(msg:Object):void {
			var data:Object = msg[0];
			var type:int = msg[1];
			var groupName:String = msg[2];
			var id:int = msg[3];
			getGroup(groupName).addUser(addUser(id + ""));
		}
		public function removeUserMsg(msg:Object):void {
			var data:Object = msg[0];
			var type:int = msg[1];
			var groupName:String = msg[2];
			var id:int = msg[3];
			getGroup(groupName).removeUser(getUser(id + ""));
		}
		public function messageMsg(msg:Object):void {
			var data:Object = msg[0];
			var type:int = msg[1];
			var groupName:String = msg[2];
			var id:int = msg[3];
			parser.receive(getGroup(groupName), getUser(id + ""), data);
		}
	}

}