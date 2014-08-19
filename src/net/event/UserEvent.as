package net.event 
{
	import flash.events.Event;
	import net.NetUser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class UserEvent extends Event
	{
		public static const ADD_USER:String = "adduser";
		public static const REMOVE_USER:String = "removeuser";
		
		public var user:NetUser;
		public function UserEvent(type:String,user:NetUser) 
		{
			super(type);
			this.user = user;
			
		}
		
	}

}