package net.http 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPRequest 
	{
		public var req:String;
		public function HTTPRequest(url:URL) 
		{
			req = "GET " + url.abspath + " HTTP/1.1\r\nHost: " + url.host + ":" + url.port + "\r\n\r\n";
		}
		
	}

}