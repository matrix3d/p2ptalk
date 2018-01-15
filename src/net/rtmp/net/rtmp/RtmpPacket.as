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

package net.rtmp.net.rtmp
{
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class RtmpPacket
	{
		public var rtmpChannel:uint;
		public var rtmpBody:ByteArray;
		
		public var rtmpBodyType:uint;
		public var rtmpBodySize:uint;
		
		public var streamTimeStamp:uint;
		public var streamChannel:uint;
		
		public var chunkSize:uint;
		public var remaining:uint;
		
		private var mObjectEncoding:uint;
		
		public function RtmpPacket(encoding:uint = ObjectEncoding.AMF0)
		{
			rtmpChannel = 0x03;
			rtmpBody = new ByteArray();
			rtmpBodyType = 0;
			rtmpBodySize = 0;
			streamTimeStamp = 0;
			streamChannel = 0;
			chunkSize = 0;
			remaining = 0;
			
			mObjectEncoding = encoding;
			rtmpBody.objectEncoding = ObjectEncoding.AMF0;
		}
		
		public function get objectEncoding():uint
		{
			return mObjectEncoding;
		}
		
		public function set objectEncoding(value:uint):void
		{
			mObjectEncoding = value;
		}
		
		public function readObject():Object
		{
			var obj:Object = null;
			
			if(rtmpBody[rtmpBody.position] == 0x11)
			{
				if(mObjectEncoding == ObjectEncoding.AMF3)
				{
					rtmpBody.readByte();
					rtmpBody.objectEncoding = ObjectEncoding.AMF3;
					obj = rtmpBody.readObject();
					rtmpBody.objectEncoding = ObjectEncoding.AMF0;
				}
			}
			else
			{
				obj = rtmpBody.readObject();
			}
			
			return obj;
		}
		
		public function writeObject(value:Object):void
		{
			if(value is uint || value is int || value is Number || value is String || value == null || value is Boolean)
			{
				rtmpBody.writeObject(value);
			}
			else
			{
				if(mObjectEncoding == ObjectEncoding.AMF3)
				{
					rtmpBody.writeByte(0x11);
					rtmpBody.objectEncoding = ObjectEncoding.AMF3;
					rtmpBody.writeObject(value);
					rtmpBody.objectEncoding = ObjectEncoding.AMF0;
				}
			}
		}
		
		public function clear():void
		{
			rtmpChannel = 0x03;
			rtmpBody.clear();
			rtmpBodyType = 0;
			rtmpBodySize = 0;
			streamTimeStamp = 0;
			streamChannel = 0;
			chunkSize = 0;
			remaining = 0;
			
			mObjectEncoding = ObjectEncoding.AMF0;
			rtmpBody.objectEncoding = ObjectEncoding.AMF0;
		}
		
		public function clone():RtmpPacket
		{
			var result:RtmpPacket = new RtmpPacket(mObjectEncoding);
			result.rtmpChannel = rtmpChannel;
			result.rtmpBody.writeBytes(rtmpBody);
			result.rtmpBody.position = 0;
			result.rtmpBodyType = rtmpBodyType;
			result.rtmpBodySize = rtmpBodySize;
			result.streamTimeStamp = streamTimeStamp;
			result.streamChannel = streamChannel;
			result.chunkSize = 0;
			result.remaining = 0;
			
			return result;
		}
		
		public function toString():String
		{
			return 	"RtmpPacket rtmpChannel = " + rtmpChannel +
					", rtmpBodyType = " + rtmpBodyType +
					", rtmpBodySize = " + rtmpBodySize +
					", streamTimeStamp = " + streamTimeStamp +
					", streamChannel = " + streamChannel;
		}
	}
}