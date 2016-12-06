package net.event 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPEvent extends Event
	{
		public static var COMPLETE:String = "httpcomp";
		public static var HEADER_COMPLETE:String = "httpheadercomp";
		public function HTTPEvent(type:String ) 
		{
			super(type);
		}
		
	}

}