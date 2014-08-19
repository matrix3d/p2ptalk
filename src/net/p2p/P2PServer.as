package net.p2p 
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import net.Group;
	import net.Server;
	import net.NetUser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class P2PServer extends Server
	{
		private var connCommand:String;
		public var conn:NetConnection;
		public function P2PServer(connCommand:String) 
		{
			this.connCommand = connCommand;
			
		}
		
		override public function start():void {
			if (conn == null) {
				conn = new NetConnection;
				conn.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			}
			conn.connect(connCommand);
		}
		
		override public function stop():void {
			conn.close();
		}
		
		override public function createGroupByName(name:String):Group {
			return P2PGroup.createByName(name);
		}
		
		override public function createGroup(group:Group):void {
			var p2pGroup:P2PGroup = group as P2PGroup;
			group.server = this;
			var netg:NetGroup = new NetGroup(conn, p2pGroup.groupSpecifier.groupspecWithAuthorizations());
			groups.push(p2pGroup);
			p2pGroup.netGroup = netg;
			netg.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
		}
		
		private function netStatus(e:NetStatusEvent):void 
		{
			if (e.currentTarget is NetGroup) {
				var group:Group = getGroupByNetGroup(e.currentTarget as NetGroup);
			}
			if (e.info.code == "NetConnection.Connect.Success") {
				dispatchEvent(new Event(Event.CONNECT));
			}else if (e.info.code == "NetGroup.Connect.Success") {
				group = getGroupByNetGroup(e.info.group as NetGroup);
				group.connectSuccess();
			}else if (e.info.code == "NetGroup.Posting.Notify") {
				parser.receive(group, getUser(e.info.message.sender),e.info.message.data);
			}else if (e.info.code == "NetGroup.SendTo.Notify") {
				parser.receive(group, getUser(e.info.message.sender),e.info.message.data);
			}else if (e.info.code == "NetGroup.Neighbor.Connect") {
				group.addUser(addUser(e.info.peerID));
			}else if (e.info.code == "NetGroup.Neighbor.Disconnect") {
				group.removeUser(removeUser(e.info.peerID));
			}
		}
		
		private function getGroupByNetGroup(netGroup:NetGroup):P2PGroup {
			for each(var g:Group in groups) {
				var p2pg:P2PGroup = g as P2PGroup;
				if (p2pg.netGroup==netGroup) {
					return p2pg;
				}
			}
			return null;
		}
	}

}