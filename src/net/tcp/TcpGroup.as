package net.tcp 
{
	import net.Group;
	import net.NetUser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpGroup extends Group
	{
		public var tcpSender:TcpMsgSender;
		
		public function TcpGroup() 
		{
			
		}
		
		override public function post(data:Object):void {
			for each(var user:NetUser in users) {
				sendTo(user, data);
			}
		}
		
		override public function sendTo(user:NetUser,data:Object):void {
			tcpSender.sendObject(createMsg(user,data));
		}
		
		public function createMsg(user:NetUser,data:Object):Object {
			return TcpConnecter.createMsg(data, TcpConnecter.MESSAGE, name, int(user.id));
		}
		
	}

}