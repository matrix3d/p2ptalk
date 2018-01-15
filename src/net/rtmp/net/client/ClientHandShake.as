/**************************************************************************************
 * Dragonfly - RTMP Server by ActionScript
 * 
 * Author: SnowMan
 * Author QQ: 228529978
 * BLOG: http://rtmp.net or http://rtmp.us.to
 * Copyright(c) AS-RTMP-Server(Dragonfly) 2012
 * SourceCode URL: http://code.google.com/p/as-rtmp-server
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **************************************************************************************/

package net.rtmp.net.client
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import net.rtmp.events.ClientHandShakeEvent;

	[Event(name = "rtmp_handshake", type = "net.rtmp.events.ClientHandShakeEvent")]
	
	public class ClientHandShake extends EventDispatcher
	{
		private static const mStep1:uint = 1;
		private static const mStep2:uint = 2;
		private static const mStep3:uint = 3;
		
		private var mHandShakeStep:uint;
		
		public function ClientHandShake()
		{
			mHandShakeStep = mStep1;
		}
		
		public function process(dataInput:IDataInput):void
		{
			switch(mHandShakeStep)
			{
				case mStep1:
					mHandShakeStep = mStep2;
					handShake1(dataInput);
					break;
				
				case mStep2:
					mHandShakeStep = mStep3;
					handShake2(dataInput);
					break;
			}
		}
		
		private function handShake1(dataInput:IDataInput):void
		{
			var result:ByteArray = new ByteArray();
			var tmp:ByteArray = new ByteArray();
			
			dataInput.readByte();
			dataInput.readBytes(tmp, 0, 1536);
			
			result.writeByte(0x03);
			result.writeBytes(tmp);
			result.writeBytes(tmp);
			result.position = 0;
			
			dispatchEvent(new ClientHandShakeEvent(ClientHandShakeEvent.HANDSHAKE, ClientHandShakeEvent.STEP_1, result));
			trace("RTMP握手步骤(HandShake step) 1");
			
			tmp.clear();
			result.clear();
		}
		
		private function handShake2(dataInput:IDataInput):void
		{
			var result:ByteArray = new ByteArray();
			dataInput.readBytes(result, 0, 1536);
			result.clear();
			dataInput.readBytes(result);
			result.position = 0;
			
			trace("RTMP握手步骤(HandShake step) 2");
			dispatchEvent(new ClientHandShakeEvent(ClientHandShakeEvent.HANDSHAKE, ClientHandShakeEvent.STEP_2, result));
			
			result.clear();
		}
	}
}