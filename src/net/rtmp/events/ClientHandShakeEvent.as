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

package net.rtmp.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class ClientHandShakeEvent extends Event
	{
		public static const HANDSHAKE:String = "rtmp_handshake";
		
		public static const STEP_1:String = "rtmp_step_1";
		public static const STEP_2:String = "rtmp_step_2";
		
		private var mStep:String;
		private var mBytes:ByteArray;
		
		public function ClientHandShakeEvent(type:String, step:String, bytes:ByteArray, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			mStep = step;
			mBytes = bytes;
		}
		
		public function get step():String
		{
			return mStep;
		}
		
		public function get bytes():ByteArray
		{
			return mBytes;
		}
		
		public override function toString():String
		{
			return "客户握手事件 类型(ClientHandShakeEvent type) = " + type + ", 步骤(step) = " + mStep;
		}
	}
}