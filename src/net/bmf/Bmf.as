package net.bmf 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Bmf 
	{
		private static var strings:Object = {};
		private static var stringi:int = 0;
		public function Bmf() 
		{
			
		}
		
		public static function readObject(by:ByteArray):Object{
			return null;
		}
		
		public static function writeObject(obj:Object):ByteArray{
			strings = {};
			stringi = 0;
			var by:ByteArray = new ByteArray;
			by.endian = Endian.LITTLE_ENDIAN;
			writeDoObj(by, obj);
			for each(var s:String in strings){
				by.writeUTFBytes(s);
			}
			return by;
		}
		public static function writeDoObj(by:ByteArray, obj:Object):void{
			
			if (obj is Array){
				writeVarint(by,0);
				writeVarint(by,obj.length);
				for each(var o:Object in obj){
					writeDoObj(by, o);
				}
			}else if (obj is int){
				writeVarint(by,1);
				//by.writeInt(int(obj));
				writeVarint(by, uint(obj));
			}else if (obj is uint){
				writeVarint(by,2);
				//by.writeUnsignedInt(uint(obj));
				writeVarint(by, uint(obj));
			}else if (obj is Number){
				writeVarint(by,3);
				by.writeFloat(Number(obj));
			}else if (obj is String){
				writeVarint(by,4);
				//by.writeUTF(String(obj));
				if (strings[obj]==null){
					strings[obj] = stringi++;
				}
				writeVarint(by, stringi);
			}else if (obj is ByteArray){
				writeVarint(by,5);
				by.writeBytes(obj as ByteArray);
			}else{
				writeVarint(by,7);
				for (var key:String in obj){
					writeDoObj(by, key);
					writeDoObj(by, obj[key]);
				}
			}
		}
		
		public static function writeVarint(output:ByteArray,value:uint):void {
			//output.writeUnsignedInt(value);
			//return;
			for (;;) {
				if (value < 0x80) {
					output.writeByte(value)
					return;
				} else {
					output.writeByte((value & 0x7F) | 0x80)
					value >>>= 7
				}
			}
		}
	}

}