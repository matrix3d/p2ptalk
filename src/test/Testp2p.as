package test 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import net.Connecter;
	import net.Group;
	import net.NetUser;
	import net.event.UserEvent;
	import net.p2p.P2PConnecter;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Testp2p extends Sprite
	{
		private var server:P2PConnecter;
		private var user
		public function Testp2p() 
		{
			server = new P2PConnecter("rtmfp:");
			server.addEventListener(Event.CONNECT, server_connect);
			server.parser.receiveFun = receive;
			server.start();
		}
		
		private function receive(group:Group, user:NetUser, data:Object):void 
		{
			trace(JSON.stringify(data, null, 4));
			trace(group.name, user.id);
		}
		
		private function server_connect(e:Event):void 
		{
			trace(e.type);
			
			var g:Group = server.createGroupByName("main");
			g.addEventListener(Event.CONNECT, g_connect);
			g.addEventListener(UserEvent.ADD_USER, g_addUser);
			g.addEventListener(UserEvent.REMOVE_USER, g_removeUser);
			server.startGroup(g);
		}
		
		private function g_removeUser(e:UserEvent):void 
		{
			trace("group",e.type);
		}
		
		private function g_addUser(e:UserEvent):void 
		{
			trace("group",e.type);
		}
		
		private function g_connect(e:Event):void 
		{
			trace("group",e.type);
		}
		
	}

}