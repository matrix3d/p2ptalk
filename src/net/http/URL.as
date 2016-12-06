package net.http 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class URL 
	{
		public var url:String;
		public var host:String;
		public var port:int;
		public var abspath:String;
		public var httphost:String;
		public function URL(url:String) 
		{
			this.url = url;
			var i:int = url.indexOf("//");
			
			var j:int = url.indexOf("/",i+2);
			if (j ==-1){
				httphost = url;
			}else{
				httphost = url.substr(0, j);
			}
			
			var u:String = url.substr(i + 2);
			i = u.indexOf("/");
			if (i ==-1){
				host = u;
				abspath = "/";
			}else{
				host = u.substr(0, i);
				u = u.substr(i);
				abspath = u;
			}
			i = host.indexOf(":");
			if (i==-1){
				port = 80;
			}else{
				var t:String = host.substr(0, i);
				port = int(host.substr(i + 1))
				host = t;
			}
		}
		
	}

}