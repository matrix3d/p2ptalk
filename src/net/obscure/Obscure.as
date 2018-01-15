package net.obscure 
{
	import com.buraks.utils.fastmem;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Obscure 
	{
		private var key:int;
		private var key2:int;
		private var mask:uint;
		private var mask2:uint;
		
		private var nkey:int;
		private var nkey2:int;
		private var nmask:uint;
		private var nmask2:uint;
		
		private var magic0:uint = 0x63223431;
		private var magic1:uint = 0x98657885;
		private var newmagic1:uint = 0x98657886;
		public function Obscure(key:int=10,nkey:int=0) 
		{
			setKey(key, nkey);
		}
		
		private function setKey(key:int, nkey:int):void{
			this.key = key;
			mask = (1 << key) - 1;
			key2 = 32 - key;
			mask2 = (1 << key2) - 1;
			
			this.nkey = nkey;
			nmask = (1 << nkey) - 1;
			nkey2 = 32 - nkey;
			nmask2 = (1 << nkey2) - 1;
		}
		
		public function fastEncode(b:ByteArray):ByteArray{
			if (b==null){
				return b;
			}
			b.length += 12;
			fastmem.fastSelectMem(b);
			var len:int = int((b.length - 12) / 4);
			
			var flag:Boolean = true;
			
			for (var i:int = 0; i < len;i++ ){
				var v:uint = fastmem.fastGetI32(i * 4);
				//inline encodeInt
				if(flag){
					fastmem.fastSetI32(((v & mask) << key2) | (v >>> key), i * 4);
				}else{
					fastmem.fastSetI32(((v & nmask) << nkey2) | (v >>> nkey), i * 4);
				}
				flag = !flag;
			}
			fastmem.fastSetI16(key, b.length - 12);
			fastmem.fastSetI16(nkey, b.length - 10);
			fastmem.fastSetI32(magic0, b.length - 8);
			fastmem.fastSetI32(newmagic1, b.length - 4);
			fastmem.fastDeselectMem();
			return b;
		}
		
		/**
		 * 加密
		 * 
		 * @param	b
		 * @return
		 */
		public function encode(b:ByteArray):ByteArray{
			if (b==null){
				return b;
			}
			if (b.length>=ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH){
				return fastEncode(b);
			}
			b.endian = Endian.LITTLE_ENDIAN;
			var len:int = int(b.length / 4);
			var flag:Boolean = true;
			for (var i:int = 0; i < len;i++ ){
				b.position = i * 4;
				var v:uint = b.readUnsignedInt();
				b.position = i * 4;
				//inline encodeInt
				if(flag){
					b.writeUnsignedInt(((v & mask) << key2) | (v >>> key));
				}else{
					b.writeUnsignedInt(((v & nmask) << nkey2) | (v >>> nkey));
				}
				flag = !flag;
			}
			b.position = b.length;
			b.writeShort(key);
			b.writeShort(nkey);
			b.writeUnsignedInt(magic0);
			b.writeUnsignedInt(newmagic1);
			b.position = 0;
			b.endian = Endian.BIG_ENDIAN;
			return b;
		}
		
		public function fastDecode(b:ByteArray):ByteArray{
			if (b==null){
				return b;
			}
			if (b.length > 8){
				fastmem.fastSelectMem(b);
				var m0:uint = uint(fastmem.fastGetI32(b.length-8));
				var m1:uint = uint(fastmem.fastGetI32(b.length-4));
				if (m0 == magic0 && (m1 == magic1 || m1 == newmagic1)){
					if (m1 == magic1){
						var len:int = int((b.length - 8) / 4);
					}else{
						len = int((b.length - 12) / 4);
						setKey(fastmem.fastGetUI16(b.length-12),fastmem.fastGetUI16(b.length - 10));
					}
					var flag:Boolean = true;
					for (var i:int = 0; i < len;i++ ){
						var v:uint = fastmem.fastGetI32(i*4);
						//inline decodeInt
						if(flag){
							fastmem.fastSetI32(((v & mask2) << key) | (v >>> key2), i * 4);
						}else{
							fastmem.fastSetI32(((v & nmask2) << nkey) | (v >>> nkey2), i * 4);
						}
						flag = !flag;
					}
					b.length = b.length - 8;
				}
				fastmem.fastDeselectMem();
			}
			return b;
		}
		
		public function decode(b:ByteArray):ByteArray{
			if (b==null){
				return b;
			}
			if (b.length > 8){
				if (b.length>=ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH){
					return fastDecode(b);
				}
				b.endian = Endian.LITTLE_ENDIAN;
				b.position = b.length - 8;
				var m0:uint = b.readUnsignedInt();
				var m1:uint = b.readUnsignedInt();
				if (m0 == magic0 && (m1 == magic1||m1==newmagic1)){
					if (m1 == magic1){
						var len:int = int((b.length - 8) / 4);
					}else{
						len = int((b.length - 12) / 4);
						b.position = b.length - 12;
						setKey(b.readShort()
						,b.readShort());
					}
					var flag:Boolean = true;
					for (var i:int = 0; i < len;i++ ){
						b.position = i * 4;
						var v:uint = b.readUnsignedInt();
						b.position = i * 4;
						//inline decodeInt
						if(flag){
							b.writeUnsignedInt(((v & mask2) << key) | (v >>> key2));
						}else{
							b.writeUnsignedInt(((v & nmask2) << nkey) | (v >>> nkey2));
						}
						flag = !flag;
					}
					b.length = b.length - 8;
				}
				b.position = 0;
				b.endian = Endian.BIG_ENDIAN;
			}
			return b;
		}
		
		public function encodeInt(v:uint):uint{
			return ((v & mask) << key2) | (v >>> key);
		}
		
		public function decodeInt(v:uint):uint{
			return ((v & mask2) << key) | (v >>> key2);
		}
		
	}

}