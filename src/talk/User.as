package talk 
{
	import net.NetUser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class User 
	{
		public var name:String;
		public var user:net.NetUser
		public function User(user:net.NetUser,name:String=null) 
		{
			this.user = user;
			this.name = name;
		}
		
	}

}