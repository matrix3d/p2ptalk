package net.rbp2 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class RBPUtils 
	{
		
		public function RBPUtils() 
		{
			
		}
		
		/**
		 * 把b合并到a里，遇到重名的用b里面的资源
		 * @param	a
		 * @param	b
		 */
		public static function merge(a:ByteArray, b:ByteArray):ByteArray{
			return merges([b,a]);
			/*var ar:RBPDecoder = new RBPDecoder(a, false);
			var br:RBPDecoder = new RBPDecoder(b, false);
			ar.decode();
			br.decode();
			var out:RBPEncoderBase = new RBPEncoderBase;
			var names:Object = {};
			for each(var f:Object in br.files){//先放b
				var name:String = f[0];
				var byte:ByteArray = f[1];
				out.dobyte(byte, name);
				names[name] = true;
			}
			for each(f in ar.files){
				name = f[0];
				if (names[name]==null){
					byte = f[1];
					out.dobyte(byte,name);
				}
			}
			return out.out;*/
			
		}
		public static function merges(rbps:Array):ByteArray{
			if (rbps.length==0){
				return null;
			}else if (rbps.length==1){
				return rbps[0];
			}else{
				var out:RBPEncoderBase = new RBPEncoderBase;
				var names:Object = {};
				for (var i:int = 0; i < rbps.length;i++ ){
					var ar:RBPDecoder = new RBPDecoder(rbps[i], false);
					ar.decode();
					for each(var f:Object in ar.files){
						var name:String = f[0];
						if (names[name]==null){
							var byte:ByteArray = f[1];
							out.dobyte(byte, name);
							names[name] = true;
						}
					}
				}
				return out.out;
			}
		}
	}

}