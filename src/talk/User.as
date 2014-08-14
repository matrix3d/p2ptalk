package talk 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class User 
	{
		public var name:String;
		public var peerID:String;
		public function User(peerID:String,name:String=null) 
		{
			this.peerID = peerID;
			this.name = name;
		}
		
	}

}