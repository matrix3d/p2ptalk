package net.rbp 
{
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class RBPEncoderBase extends EventDispatcher
	{
		public var isAsync:Boolean;
		public var out:ByteArray = new ByteArray;
		public function RBPEncoderBase() 
		{
			out.endian = Endian.LITTLE_ENDIAN;
		}
		
		public function dobyte(b:ByteArray, name:String):void{
			if (isAsync){
				out.clear();
			}
			out.writeUTF(name);
			out.writeUnsignedInt(b.length);
			out.writeBytes(b);
			if (isAsync){
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			}
		}
	}

}