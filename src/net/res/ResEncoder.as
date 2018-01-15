package net.res 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class ResEncoder 
	{
		private static var names:Array = [];
		private static var bodys:Array = [];
		public function ResEncoder() 
		{
			
		}
		
		public static function encode(o:Object):Object{
			return o;
			names = [];
			bodys = [];
			var out:Object = {};
			out.__v = "res1";
			var i:int = 0;
			for (var id:String in o){
				addData("__id", id,i);
				var lineObj:Object = o[id];
				for (var name:String in lineObj){
					addData(name, lineObj[name],i);
				}
				i++;
			}
			out.names = names;
			out.bodys = bodys;
			return out;
		}
		
		public static function addData(name:String, data:Object,i:int):void{
			var namei:int = names.indexOf(name);
			if (namei==-1){
				namei = names.length;
				names.push(name);
				bodys.push([]);
			}
			var body:Array = bodys[namei];
			body[i] = data;
		}
	}

}