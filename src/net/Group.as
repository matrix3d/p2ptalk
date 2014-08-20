package net 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.event.UserEvent;
	/**
	 * 一组用户
	 * @author lizhi
	 */
	public class Group extends EventDispatcher
	{
		public var users:Vector.<NetUser> = new Vector.<NetUser>;
		public var connnecter:Connecter;
		public var name:String;
		public function Group() 
		{
			
		}
		
		public function post(data:Object):void {
			
		}
		
		public function sendTo(user:NetUser,data:Object):void {
			
		}
		
		public function connectSuccess():void {
			dispatchEvent(new Event(Event.CONNECT));
		}
		
		public function addUser(user:NetUser):void {
			if (users.indexOf(user)==-1) {
				users.push(user);
				dispatchEvent(new UserEvent(UserEvent.ADD_USER, user));
			}
		}
		
		public function removeUser(user:NetUser):void {
			var i:int = users.indexOf(user);
			if (i != -1) {
				users.splice(i, 1);
				dispatchEvent(new UserEvent(UserEvent.REMOVE_USER, user));
			}
		}
		
	}

}