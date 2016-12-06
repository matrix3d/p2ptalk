package net.http 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPHeaderLoader extends HTTPLoader
	{
		
		public function HTTPHeaderLoader() 
		{
		}
		
		override protected function parser_change(e:Event):void 
		{
			if (parser.headerOver){
				if(socket.connected)
				socket.close();
			}
			super.parser_change(e);
		}
		
	}

}