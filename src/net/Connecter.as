package net 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * 服务器
	 * @author lizhi
	 */
	public class Connecter extends EventDispatcher
	{
		public var groups:Vector.<Group>=new Vector.<Group>;
		public var users:Vector.<NetUser> = new Vector.<NetUser>;
		public var parser:MsgParser;
		public function Connecter() 
		{
			parser = new MsgParser;
			parser.server = this;
		}
		
		public function start():void {
			
		}
		
		public function stop():void {
			
		}
		
		public function createGroupByName(name:String):Group {
			return null;
		}
		
		public function startGroup(group:Group):void {
		}
		
		public function getUser(id:String):NetUser {
			for each(var user:NetUser in users) {
				if (user.id==id) {
					return user;
				}
			}
			return null;
		}
		
		public function addUser(id:String):NetUser {
			var user:NetUser = getUser(id);
			if (user == null) {
				user = new NetUser;
				user.id = id;
				users.push(user);
			}
			return user;
		}
		
		public function removeUser(id:String):NetUser {
			for (var i:int = 0; i < users.length;i++ ) {
				var user:NetUser = users[i];
				if (user.id==id) {
					users.splice(i, 1);
					return user;
				}
			}
			return null;
		}
		
		public function connectSuccess():void {
			dispatchEvent(new Event(Event.CONNECT));
		}
		
		public function getGroup(name:String):Group {
			for each(var g:Group in groups) {
				if (g.name == name) return g;
			}
			return null;
		}
	}

}