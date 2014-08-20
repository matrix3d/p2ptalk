package net 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class MsgParser 
	{
		public var server:Connecter;
		public var receiveFun:Function;
		public function MsgParser() 
		{
			
		}
		
		public function receive(group:Group, user:NetUser, data:Object):void {
			if (receiveFun!=null) {
				receiveFun(group, user, data);
			}
		}
		
	}

}