package net.http 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPHeader 
	{
		public var obj:Object = {};
		public function HTTPHeader(txt:String) 
		{
			var lines:Array = txt.split(/[\r\n]+/);
			for each(var line:String in lines) {
				if(line!=""){
					var i:int = line.indexOf(": ");
					var key:String = line.substr(0, i);
					var value:String = i ==-1?"":line.substr(i + 2);
					if (i==-1&&line.indexOf("GET ")==0){
						var arr:Array = line.split(" ");
						key = arr[0];
						value = arr[1];
					}
					obj[key] = value;
				}
			}
		}
		
	}

}