package net.tcp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpServerReaderCalbak extends TcpReaderCalbak {
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

}