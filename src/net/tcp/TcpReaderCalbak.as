package net.tcp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class TcpReaderCalbak 
	{
		private var conn:TcpConnecter
		public function TcpReaderCalbak(conn:TcpConnecter) 
		{
			this.conn = conn;
			
		}
		
		public function calbak(msg:Object):void 
		{
			var type:int = msg[1];
			switch(type) {
				case TcpConnecter.ADD_USER:
					conn.addUserMsg(msg);
					break;
				case TcpConnecter.REMOVE_USER:
					conn.removeUserMsg(msg);
					break;
				case TcpConnecter.MESSAGE:
					conn.messageMsg(msg);
					break;
			}
		}
		
	}

}