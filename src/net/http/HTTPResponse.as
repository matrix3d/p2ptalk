package net.http 
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPResponse 
	{
		public var output:IDataOutput;
		
		public function HTTPResponse(output:IDataOutput) 
		{
			this.output = output;
			
		}
		
		public function writeHead(status:int, type:String, len:int):void{
			output.writeUTFBytes(
				"HTTP/1.1 " + status + "\r\n" +
				"Server: lzair\r\n" +
				"Date: " + new Date() + "\r\n" +
				"Content-Type: " + type+"\r\n" +
				//"transfer-encoding: " + "chunked"+"\r\n" +
				//"Accept-Ranges :" + "bytes"+"\r\n" +
				//"Connection: " + "keep-alive"+"\r\n" +
				"Content-Length: " + len + "\r\n" +
				"\r\n"
			);
		}
		
		public function write(input:IDataInput, status:int, type:String):void{
			writeHead(status, type, input.bytesAvailable);
			while (input.bytesAvailable){
				output.writeByte(input.readByte());
			}
		}
		
		public function writeTxt(data:String, status:int, type:String):void{
			var byte:ByteArray = new ByteArray;
			byte.writeUTFBytes(data);
			writeHead(status, type, byte.length);
			output.writeUTFBytes(data);
		}
	}

}