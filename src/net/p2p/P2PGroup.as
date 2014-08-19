package net.p2p 
{
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	import net.Group;
	import net.NetUser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class P2PGroup extends Group
	{
		public var groupSpecifier:GroupSpecifier;
		public var netGroup:NetGroup;
		private var helpStr:String;
		public function P2PGroup(groupSpecifier:GroupSpecifier) 
		{
			this.groupSpecifier = groupSpecifier;
			
		}
		
		public static function createByName(name:String):P2PGroup {
			var gs:GroupSpecifier = new GroupSpecifier(name);
			gs.postingEnabled = true;
			gs.routingEnabled = true;
			gs.serverChannelEnabled = true;
			gs.ipMulticastMemberUpdatesEnabled = true;
			gs.addIPMulticastAddress("225.225.0.1:30303");
			return new P2PGroup(gs);
		}
		
		override public function post(data:Object):void {
			helpStr = netGroup.sendToAllNeighbors(createMsg(data));
		}
		
		override public function sendTo(user:NetUser,data:Object):void {
			helpStr = netGroup.sendToNearest(createMsg(data), netGroup.convertPeerIDToGroupAddress(user.id));
		}
		
		public function createMsg(data:Object):Object {
			var p2pServer:P2PServer = server as P2PServer;
			var msg:Object = { };
			msg.sender = p2pServer.conn.nearID
			msg.data = data;
			return msg;
		}
	}

}