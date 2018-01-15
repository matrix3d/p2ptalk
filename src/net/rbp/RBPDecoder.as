package net.rbp 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	/**
	 * 判断是否长度2
	 * 读名字长度
	 * 判断长度符合
	 * 读名字
	 * 判断长度是否4
	 * 读长度
	 * 判断长度符合
	 * 读body
	 * @author lizhi
	 */
	public class RBPDecoder
	{
		public var files:Array = [];
		public var b:IDataInput;
		private var readHeadering:Boolean = true;
		public var stats:int = 0;
		public var needLen:int = 2;
		private var async:Boolean;
		
		public var fileName:String;
		public var content:ByteArray;
		public var position:int = 0;
		public function RBPDecoder(b:IDataInput,async:Boolean) 
		{
			this.async = async;
			if(b){
			this.b = b;
			b.endian = Endian.LITTLE_ENDIAN;
			}
		}
		
		public function setByte(b:IDataInput):void{
			this.b = b;
			b.endian = Endian.LITTLE_ENDIAN;
		}
		
		public function decode():void{
			while (readLine()){
			}
		}
		
		public function readLine():Boolean{
			if (b&&b.bytesAvailable>=needLen){
				position += needLen;
				if (stats==0){//读名字长度
					needLen = b.readUnsignedShort();
				}else if (stats==1){//读长度
					fileName = b.readUTFBytes(needLen);
					needLen = 4;
				}else if (stats==2){//读文件长度
					needLen = b.readUnsignedInt();
				}else {//读文件
					content = new ByteArray;
					if(needLen>0){
						b.readBytes(content, 0, needLen);
					}
					if(!async){
						files.push([fileName, content]);
					}
					needLen = 2;
				}
				stats++;
				stats = stats % 4;
				return true;
			}
			return false;
			/*
			var f:Array = [];
			f.push(b.readUTF());
			var len:int = b.readUnsignedInt();
			f.push(len);
			var o:ByteArray = new ByteArray;
			b.readBytes(o, 0, len);
			f.push(o);
			o.position = 0;
			files.push(f);*/
		}
		
		public function close():void{
			b = null;
		}
	}

}